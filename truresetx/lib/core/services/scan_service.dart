import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Pose types are returned by CameraService.detectPosesInImage; no direct ML Kit import needed here
import '../../data/models/scan_models.dart';
import 'camera_service.dart';
import 'ai_service.dart';

/// ScanService performs body scans using CameraService + ML Kit and refines via AIService
class ScanService {
  ScanService({required this.camera, required this.ai});

  final CameraService camera;
  final AIService ai;

  /// Capture an image from the camera and run a body scan flow
  Future<ScanResult?> scanBodyFromCamera(
      {required String userId, double? heightCm}) async {
    final file = await camera.takePicture();
    if (file == null) return null;
    return await scanBodyFromImage(
        userId: userId, imageFile: file, heightCm: heightCm);
  }

  /// Analyze a provided image file and return a ScanResult (local estimate + AI refine)
  Future<ScanResult?> scanBodyFromImage(
      {required String userId,
      required File imageFile,
      double? heightCm}) async {
    try {
      final poses = await camera.detectPosesInImage(imageFile);

      // Basic local heuristics: estimate person pixel height from pose landmarks
      double pixelHeight = 0.0;
      if (poses.isNotEmpty) {
        final p = poses.first;
        final yValues = <double>[];
        for (final landmark in p.landmarks.values) {
          yValues.add(landmark.y);
        }
        if (yValues.isNotEmpty) {
          final minY = yValues.reduce(min);
          final maxY = yValues.reduce(max);
          pixelHeight = maxY - minY;
        }
      }

      // Placeholder approximate measures (waist/hip) using image width heuristics
      const imageWidth = 100.0; // unknown on some platforms; keep safe fallback
      const waistPx = imageWidth * 0.35;
      const hipPx = imageWidth * 0.38;

      double scale = 0.0;
      if (heightCm != null && pixelHeight > 0) {
        scale = heightCm / pixelHeight; // cm per pixel
      }

      final waistCm = scale > 0 ? waistPx * scale : 0.0;
      final hipCm = scale > 0 ? hipPx * scale : 0.0;

      // Compute navy estimate when possible
      double estimatedBodyFat = 0.0;
      double confidence = 0.0;
      if (heightCm != null && waistCm > 0) {
        // use a simple heuristic: navy male formula as fallback (note: requires neck measure ideally)
        // We'll compute a coarse estimate and low confidence
        estimatedBodyFat = _naiveNavyEstimate(
            waistCm: waistCm,
            neckCm: waistCm * 0.38,
            heightCm: heightCm,
            isFemale: false);
        confidence = 0.5; // local heuristic low confidence
      }

      // Build local result
      final local = {
        'estimated_body_fat_pct': estimatedBodyFat,
        'confidence': confidence,
        'method': 'image',
        'body_measures': {'waist_cm': waistCm, 'hip_cm': hipCm},
        'composition': {},
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Ask AI to refine the estimate (send only numeric metrics, not raw image)
      final prompt = _buildScanRefinementPrompt(local);
      final Map<String, dynamic>? aiJson = await ai.chatCompletionJson(prompt);

      Map<String, dynamic> finalJson = {};
      if (aiJson != null) {
        finalJson = {...local, ...aiJson};
      } else {
        finalJson = local;
      }

      // Ensure required fields
      finalJson['id'] = 'scan-${DateTime.now().millisecondsSinceEpoch}';
      finalJson['user_id'] = userId;
      finalJson['image_path'] = imageFile.path;

      return ScanResult.fromJsonSafe(finalJson);
    } catch (e) {
      print('ScanService.scanBodyFromImage error: $e');
      return null;
    }
  }

  double _naiveNavyEstimate(
      {required double waistCm,
      required double neckCm,
      required double heightCm,
      required bool isFemale}) {
    final safeA = max(waistCm - neckCm, 1e-3);
    final safeH = max(heightCm, 1e-3);
    if (!isFemale) {
      return (86.010 * log(safeA) / ln10) -
          (70.041 * log(safeH) / ln10) +
          36.76;
    } else {
      // need hip for female formula; fallback to male-like estimate scaled
      return (163.205 *
              log(max(waistCm + (hipCmFallback(waistCm) - neckCm), 1e-3)) /
              ln10) -
          (97.684 * log(safeH) / ln10) -
          78.387;
    }
  }

  double hipCmFallback(double waistCm) => waistCm * 1.05;

  String _buildScanRefinementPrompt(Map<String, dynamic> measures) {
    final metricsJson = jsonEncode(measures);
    return '''You receive measurements and segmentation metrics (JSON): $metricsJson
Return ONLY valid JSON with keys: estimated_body_fat_pct (number), confidence (0-1), method (image|caliper|bia|hybrid), notes (string), recommended_follow_up (array).
If confidence < 0.7 include recommended_follow_up suggestions.''';
  }
}

final scanServiceProvider = Provider<ScanService>((ref) {
  final camera = ref.read(cameraServiceProvider);
  final ai = ref.read(aiServiceProvider);
  return ScanService(camera: camera, ai: ai);
});

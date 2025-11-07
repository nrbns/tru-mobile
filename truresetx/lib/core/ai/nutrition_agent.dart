import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:uuid/uuid.dart';

import '../services/ai_service.dart';
import '../services/camera_service.dart';

/// Nutrition Agent - Specialized AI for food recognition and nutrition planning
class NutritionAgent {
  NutritionAgent({
    required AIService aiService,
    required CameraService cameraService,
  })  : _aiService = aiService,
        _cameraService = cameraService;

  final AIService _aiService;
  final CameraService _cameraService;

  // Simple in-memory cache for food -> RecognizedFood to avoid repeated AI calls
  final Map<String, RecognizedFood> _nutritionCache = {};
  Box<dynamic>? _cacheBox;
  bool _cacheLoaded = false;

  // Stream controller to publish detection events to the UI
  final StreamController<RecognizedFood> _detectionController =
      StreamController<RecognizedFood>.broadcast();

  Stream<RecognizedFood> get detectionStream => _detectionController.stream;

  // Controls for live scanning
  bool _processingLive = false;
  Timer? _liveDebounceTimer;

  // Config
  final double imageLabelConfidenceThreshold = 0.7;
  final double liveDetectionConfidenceToQuery = 0.8;
  final Duration liveDebounceDuration = const Duration(milliseconds: 800);
  final Duration aiCallTimeout = const Duration(seconds: 8);

  /// Scan food using camera and AI recognition
  Future<FoodScanResult> scanFood({
    required String userId,
    String? imagePath,
  }) async {
    final uuid = const Uuid().v4(); // unique per scan
    if (imagePath != null) {
      return await _processFoodImage(imagePath, userId, scanId: uuid);
    } else {
      return await _startLiveFoodScan(userId, scanId: uuid);
    }
  }

  /// Process food image with AI
  Future<FoodScanResult> _processFoodImage(
    String imagePath,
    String userId, {
    required String scanId,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(
          confidenceThreshold: imageLabelConfidenceThreshold),
    );

    try {
      final labels = await imageLabeler.processImage(inputImage);

      final foodLabels = labels
          .where((label) => _isFoodRelated(label.label.toLowerCase()))
          .toList();

      final recognizedFoods = <RecognizedFood>[];
      for (final label in foodLabels) {
        final key = label.label.toLowerCase();
        RecognizedFood? food;
        if (_nutritionCache.containsKey(key)) {
          food = _nutritionCache[key];
        } else {
          // Ensure cache is loaded before making AI calls
          await _ensureCacheLoaded();
          food = await _getFoodNutritionData(label.label, userId).timeout(
            aiCallTimeout,
            onTimeout: () => null,
          );
          if (food != null) {
            _nutritionCache[key] = food;
            unawaited(_saveToCache(key, food));
          }
        }

        if (food != null) recognizedFoods.add(food);
      }

      final confidence =
          foodLabels.isNotEmpty ? foodLabels.first.confidence : 0.0;

      return FoodScanResult(
        id: scanId,
        userId: userId,
        imagePath: imagePath,
        recognizedFoods: recognizedFoods,
        confidence: confidence,
        scanTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error processing food image: $e');
      return FoodScanResult(
        id: scanId,
        userId: userId,
        imagePath: imagePath,
        recognizedFoods: [],
        confidence: 0.0,
        scanTime: DateTime.now(),
      );
    } finally {
      await imageLabeler.close();
    }
  }

  /// Start live food scanning
  Future<FoodScanResult> _startLiveFoodScan(String userId,
      {required String scanId}) async {
    await _cameraService.initializeCamera();

    // Start image labeling via CameraService callback-based API
    _cameraService.startImageLabeling((labels) {
      // debounce rapid emissions
      _liveDebounceTimer?.cancel();
      _liveDebounceTimer = Timer(liveDebounceDuration, () {
        final foodLabels = labels
            .where((label) => _isFoodRelated(label.label.toLowerCase()))
            .where(
                (label) => label.confidence >= liveDetectionConfidenceToQuery)
            .toList();

        if (foodLabels.isNotEmpty) {
          _processLiveFoodDetection(foodLabels, userId);
        }
      });
    });

    return FoodScanResult(
      id: scanId,
      userId: userId,
      imagePath: null,
      recognizedFoods: [],
      confidence: 0.0,
      scanTime: DateTime.now(),
    );
  }

  /// Stop live scanning and cleanup
  Future<void> stopLiveScan() async {
    _liveDebounceTimer?.cancel();
    // Stop the camera image stream (keeps controller available)
    await _cameraService.stopCameraStream();
  }

  /// Process live food detection (now returns Future)
  Future<void> _processLiveFoodDetection(
      List<ImageLabel> foodLabels, String userId) async {
    if (_processingLive) return;
    _processingLive = true;
    try {
      for (final label in foodLabels) {
        if (label.confidence > liveDetectionConfidenceToQuery) {
          final key = label.label.toLowerCase();
          RecognizedFood? food = _nutritionCache[key];
          if (food == null) {
            food = await _getFoodNutritionData(label.label, userId)
                .timeout(aiCallTimeout, onTimeout: () => null);
            if (food != null) _nutritionCache[key] = food;
          }
          if (food != null) {
            _sendFoodForConfirmation(food, userId);
          }
        }
      }
    } catch (e) {
      debugPrint('Error in live detection processing: $e');
    } finally {
      _processingLive = false;
    }
  }

  /// Get nutrition data for recognized food (safe parsing, caching, validation)
  Future<RecognizedFood?> _getFoodNutritionData(
      String foodName, String userId) async {
    final prompt = _buildNutritionPrompt(foodName);

    try {
      final response = await _aiService.chatCompletion(prompt).timeout(
            aiCallTimeout,
            onTimeout: () => throw TimeoutException('AI request timed out'),
          );

      // Validate JSON shape safely on a background isolate if large
      final nutritionData =
          await compute(_safeJsonDecode, response) as Map<String, dynamic>?;

      if (nutritionData == null) return null;
      final validated = _validateNutritionJson(nutritionData);
      if (!validated) return null;

      final recognized = RecognizedFood.fromJsonSafe(nutritionData);
      return recognized;
    } catch (e) {
      debugPrint('Error getting nutrition data for "$foodName": $e');
      return null;
    }
  }

  String _buildNutritionPrompt(String foodName) {
    // Clear, strict JSON schema + instructions to respond EXACTLY with JSON only
    return '''
You are a nutrition assistant. Return ONLY valid JSON that matches the schema below. No extra text.

Schema:
{
  "name": "string",
  "serving_size": "string",
  "calories": number,
  "macros": {
    "protein_g": number,
    "carbs_g": number,
    "fat_g": number,
    "fiber_g": number
  },
  "micronutrients": {
    "vitamin_c_mg": number,
    "iron_mg": number,
    "calcium_mg": number
  },
  "health_benefits": ["string"],
  "allergens": ["string"],
  "portion_estimate": "string"
}

Provide realistic, concise numeric values and units where needed.
Food: $foodName
    ''';
  }

  bool _validateNutritionJson(Map<String, dynamic> json) {
    // Basic shape checks; expand as needed
    if (!json.containsKey('name') || !json.containsKey('calories')) {
      return false;
    }
    if (json['macros'] == null || json['micronutrients'] == null) {
      return false;
    }
    return true;
  }

  static dynamic _safeJsonDecode(String input) {
    try {
      return jsonDecode(input);
    } catch (_) {
      return null;
    }
  }

  bool _isFoodRelated(String label) {
    final foodKeywords = [
      'food',
      'meal',
      'dish',
      'cuisine',
      'recipe',
      'cooking',
      'apple',
      'banana',
      'bread',
      'pasta',
      'rice',
      'chicken',
      'beef',
      'fish',
      'vegetable',
      'fruit',
      'salad',
      'soup',
      'pizza',
      'burger',
      'sandwich',
      'cake',
      'cookie',
      'drink',
      'coffee',
      'tea',
      'juice',
      'milk',
      'yogurt',
      'cheese',
      'egg',
      'meat',
      'seafood',
      'nuts',
      'grains',
      'cereal'
    ];

    return foodKeywords.any((keyword) => label.contains(keyword));
  }

  void _sendFoodForConfirmation(RecognizedFood food, String userId) {
    // Send to UI (replace print with an event/stream or Riverpod notifier)
    debugPrint('Food detected: ${food.name} - Please confirm portion size');
    if (!_detectionController.isClosed) {
      _detectionController.add(food);
    }
  }

  // ignore: unused_element
  Future<void> _logFoodItem(
      String userId, RecognizedFood food, String mealType) async {
    debugPrint('Logging food: ${food.name} for $mealType');
    // TODO: implement persistent DB write
  }

  // ignore: unused_element
  Future<void> _updateDailyMacros(String userId, RecognizedFood food) async {
    debugPrint('Updating macros for: ${food.name}');
  }

  // ignore: unused_element
  Future<void> _suggestNextMeal(String userId) async {
    debugPrint('Suggesting next meal for user: $userId');
  }

  /// Ensure the Hive cache box is loaded into memory
  Future<void> _ensureCacheLoaded() async {
    if (_cacheLoaded) return;
    try {
      _cacheBox ??= await Hive.openBox('nutrition_cache');
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiryMs = const Duration(days: 30).inMilliseconds;
      final keysToRemove = <dynamic>[];
      for (final key in _cacheBox!.keys) {
        try {
          final raw = _cacheBox!.get(key);
          if (raw is String) {
            final wrapper = _safeJsonDecode(raw) as Map<String, dynamic>?;
            if (wrapper != null) {
              final ts = wrapper['ts'] is int
                  ? wrapper['ts'] as int
                  : int.tryParse('${wrapper['ts']}') ?? 0;
              if (now - ts > expiryMs) {
                keysToRemove.add(key);
                continue;
              }
              final Map<String, dynamic>? map =
                  wrapper['data'] as Map<String, dynamic>?;
              if (map != null) {
                _nutritionCache[key.toString()] =
                    RecognizedFood.fromJsonSafe(map);
              }
            }
          }
        } catch (_) {
          // ignore individual entry parse errors
        }
      }
      // prune expired keys
      for (final k in keysToRemove) {
        try {
          await _cacheBox!.delete(k);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Failed to load nutrition cache: $e');
    }
    _cacheLoaded = true;
  }

  Future<void> _saveToCache(String key, RecognizedFood food) async {
    try {
      _cacheBox ??= await Hive.openBox('nutrition_cache');
      final wrapper = {
        'ts': DateTime.now().millisecondsSinceEpoch,
        'data': food.toJson()
      };
      await _cacheBox!.put(key, jsonEncode(wrapper));
    } catch (e) {
      debugPrint('Failed to save nutrition cache: $e');
    }
  }

  /// Dispose resources used by the agent
  Future<void> dispose() async {
    try {
      await stopLiveScan();
    } catch (_) {}
    try {
      await _detectionController.close();
    } catch (_) {}
    try {
      await _cacheBox?.close();
    } catch (_) {}
  }
}

/// Models: add safe factory helpers to handle ints/doubles/strings reliably
class RecognizedFood {
  RecognizedFood({
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.macros,
    required this.micronutrients,
    required this.healthBenefits,
    required this.allergens,
    required this.portionEstimate,
  });

  factory RecognizedFood.fromJsonSafe(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    Map<String, double> mapToDouble(Map? m) {
      if (m == null) return {};
      return m.map((k, v) => MapEntry(k.toString(), toDouble(v)));
    }

    return RecognizedFood(
      name: json['name']?.toString() ?? 'unknown',
      servingSize: json['serving_size']?.toString() ?? '',
      calories: toDouble(json['calories']),
      macros: mapToDouble(json['macros'] as Map?),
      micronutrients: mapToDouble(json['micronutrients'] as Map?),
      healthBenefits: (json['health_benefits'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allergens:
          (json['allergens'] as List?)?.map((e) => e.toString()).toList() ?? [],
      portionEstimate: json['portion_estimate']?.toString() ?? '',
    );
  }

  final String name;
  final String servingSize;
  final double calories;
  final Map<String, double> macros;
  final Map<String, double> micronutrients;
  final List<String> healthBenefits;
  final List<String> allergens;
  final String portionEstimate;

  RecognizedFood adjustPortion(double multiplier) {
    return RecognizedFood(
      name: name,
      servingSize: servingSize,
      calories: calories * multiplier,
      macros: macros.map((k, v) => MapEntry(k, v * multiplier)),
      micronutrients: micronutrients.map((k, v) => MapEntry(k, v * multiplier)),
      healthBenefits: healthBenefits,
      allergens: allergens,
      portionEstimate: portionEstimate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'serving_size': servingSize,
      'calories': calories,
      'macros': macros,
      'micronutrients': micronutrients,
      'health_benefits': healthBenefits,
      'allergens': allergens,
      'portion_estimate': portionEstimate,
    };
  }
}

class FoodScanResult {
  FoodScanResult({
    required this.id,
    required this.userId,
    this.imagePath,
    required this.recognizedFoods,
    required this.confidence,
    required this.scanTime,
  });
  final String id;
  final String userId;
  final String? imagePath;
  final List<RecognizedFood> recognizedFoods;
  final double confidence;
  final DateTime scanTime;
}

// Provider
final nutritionAgentProvider = Provider<NutritionAgent>((ref) {
  final agent = NutritionAgent(
    aiService: ref.read(aiServiceProvider),
    cameraService: ref.read(cameraServiceProvider),
  );

  ref.onDispose(() {
    // Ensure resources are cleaned when provider is disposed
    unawaited(agent.dispose());
  });

  return agent;
});

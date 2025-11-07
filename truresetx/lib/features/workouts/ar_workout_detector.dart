import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/exercise_models.dart';
import '../../data/models/workout_models.dart';

/// AR Workout Detector with real camera integration
class ARWorkoutDetector extends ConsumerStatefulWidget {
  const ARWorkoutDetector({
    super.key,
    required this.exercise,
    required this.workoutExercise,
    required this.onRepDetected,
    required this.onFormErrorsDetected,
    required this.onFormScoreUpdated,
  });
  final Exercise exercise;
  final WorkoutExercise workoutExercise;
  final Function(RepMetric) onRepDetected;
  final Function(List<String>) onFormErrorsDetected;
  final Function(double) onFormScoreUpdated;

  @override
  ConsumerState<ARWorkoutDetector> createState() => _ARWorkoutDetectorState();
}

class _ARWorkoutDetectorState extends ConsumerState<ARWorkoutDetector>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isDetecting = false;
  int _currentRep = 0;
  double _formScore = 100.0;
  List<String> _currentErrors = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Camera permission denied');
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize camera controller
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startDetection();
      }
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startDetection() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _isDetecting = true;
      });
      _pulseController.repeat(reverse: true);
      _startPoseDetection();
    }
  }

  void _stopDetection() {
    setState(() {
      _isDetecting = false;
    });
    _pulseController.stop();
  }

  void _startPoseDetection() {
    // Simulate pose detection with real camera frames
    _cameraController!.startImageStream((CameraImage image) {
      if (_isDetecting) {
        _processCameraFrame(image);
      }
    });
  }

  void _processCameraFrame(CameraImage image) {
    // Convert camera image to processable format
    final imageBytes = _convertCameraImageToBytes(image);

    // Simulate pose detection analysis
    _analyzePose(imageBytes);
  }

  Uint8List _convertCameraImageToBytes(CameraImage image) {
    // Convert YUV420 format to RGB
    // Use only the raw plane data for the simplified conversion.
    // final int width = image.width; // unused in simplified conversion
    // final int height = image.height; // unused in simplified conversion
    // final int uvRowStride = image.planes[1].bytesPerRow; // unused
    // final int uvPixelStride = image.planes[1].bytesPerPixel!; // unused

    // This is a simplified conversion - in real implementation,
    // you would use proper YUV to RGB conversion
    return Uint8List.fromList(image.planes[0].bytes);
  }

  void _analyzePose(Uint8List imageBytes) {
    // Simulate pose detection with exercise-specific analysis
    final analysis = _performPoseAnalysis(imageBytes);

    if (analysis['repDetected'] == true) {
      _handleRepDetection();
    }

    if (analysis['formErrors'] != null) {
      _handleFormErrors(analysis['formErrors']);
    }

    if (analysis['formScore'] != null) {
      _handleFormScoreUpdate(analysis['formScore']);
    }
  }

  Map<String, dynamic> _performPoseAnalysis(Uint8List imageBytes) {
    // Simulate AI pose analysis based on exercise type
    final exerciseType = widget.exercise.name.toLowerCase();

    // Simulate different analysis based on exercise
    if (exerciseType.contains('push') || exerciseType.contains('press')) {
      return _analyzePushExercise(imageBytes);
    } else if (exerciseType.contains('squat') ||
        exerciseType.contains('lunge')) {
      return _analyzeSquatExercise(imageBytes);
    } else if (exerciseType.contains('pull') || exerciseType.contains('row')) {
      return _analyzePullExercise(imageBytes);
    } else {
      return _analyzeGenericExercise(imageBytes);
    }
  }

  Map<String, dynamic> _analyzePushExercise(Uint8List imageBytes) {
    // Simulate push exercise analysis (push-ups, bench press, etc.)
    final random = DateTime.now().millisecond;

    return {
      'repDetected': random % 30 == 0, // Simulate rep detection
      'formErrors': _getPushExerciseErrors(random),
      'formScore': _calculateFormScore(random),
    };
  }

  Map<String, dynamic> _analyzeSquatExercise(Uint8List imageBytes) {
    // Simulate squat exercise analysis
    final random = DateTime.now().millisecond;

    return {
      'repDetected': random % 25 == 0, // Simulate rep detection
      'formErrors': _getSquatExerciseErrors(random),
      'formScore': _calculateFormScore(random),
    };
  }

  Map<String, dynamic> _analyzePullExercise(Uint8List imageBytes) {
    // Simulate pull exercise analysis
    final random = DateTime.now().millisecond;

    return {
      'repDetected': random % 35 == 0, // Simulate rep detection
      'formErrors': _getPullExerciseErrors(random),
      'formScore': _calculateFormScore(random),
    };
  }

  Map<String, dynamic> _analyzeGenericExercise(Uint8List imageBytes) {
    // Simulate generic exercise analysis
    final random = DateTime.now().millisecond;

    return {
      'repDetected': random % 40 == 0, // Simulate rep detection
      'formErrors': _getGenericExerciseErrors(random),
      'formScore': _calculateFormScore(random),
    };
  }

  List<String> _getPushExerciseErrors(int random) {
    final errors = <String>[];
    if (random % 7 == 0) errors.add('Elbows flaring out');
    if (random % 11 == 0) errors.add('Incomplete range of motion');
    if (random % 13 == 0) errors.add('Hip sagging');
    if (random % 17 == 0) errors.add('Head not aligned');
    return errors;
  }

  List<String> _getSquatExerciseErrors(int random) {
    final errors = <String>[];
    if (random % 5 == 0) errors.add('Knees caving in');
    if (random % 9 == 0) errors.add('Insufficient depth');
    if (random % 11 == 0) errors.add('Forward lean');
    if (random % 13 == 0) errors.add('Heels lifting');
    return errors;
  }

  List<String> _getPullExerciseErrors(int random) {
    final errors = <String>[];
    if (random % 6 == 0) errors.add('Shoulder shrugging');
    if (random % 8 == 0) errors.add('Incomplete range of motion');
    if (random % 12 == 0) errors.add('Momentum swinging');
    if (random % 14 == 0) errors.add('Grip too wide');
    return errors;
  }

  List<String> _getGenericExerciseErrors(int random) {
    final errors = <String>[];
    if (random % 10 == 0) errors.add('Poor posture');
    if (random % 15 == 0) errors.add('Incomplete movement');
    if (random % 20 == 0) errors.add('Rushing the movement');
    return errors;
  }

  double _calculateFormScore(int random) {
    // Simulate form score calculation (70-100 range)
    return 70 + (random % 30).toDouble();
  }

  void _handleRepDetection() {
    setState(() {
      _currentRep++;
    });

    final repMetric = RepMetric(
      repNumber: _currentRep,
      timestamp: DateTime.now(),
      metrics: {
        'form_score': _formScore,
        'errors': _currentErrors,
        'duration': 2.5, // Simulated rep duration
      },
      quality: _formScore / 100,
      errors: _currentErrors,
    );

    widget.onRepDetected(repMetric);

    // Reset for next rep
    _currentErrors = [];
    _formScore = 100.0;
  }

  void _handleFormErrors(List<String> errors) {
    setState(() {
      _currentErrors = errors;
    });
    widget.onFormErrorsDetected(errors);
  }

  void _handleFormScoreUpdate(double score) {
    setState(() {
      _formScore = score;
    });
    widget.onFormScoreUpdated(score);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // AR Overlays
        if (_isDetecting) _buildAROverlays(),

        // Controls
        _buildControls(),
      ],
    );
  }

  Widget _buildAROverlays() {
    return Stack(
      children: [
        // Form analysis indicator
        Positioned(
          top: 50,
          left: 20,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _formScore >= 80
                          ? Colors.green
                          : _formScore >= 60
                              ? Colors.orange
                              : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Score: ${_formScore.toInt()}%',
                        style: TextStyle(
                          color: _formScore >= 80
                              ? Colors.green
                              : _formScore >= 60
                                  ? Colors.orange
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_currentErrors.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Errors: ${_currentErrors.length}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Rep counter
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withAlpha((0.3 * 255).round()),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              '$_currentRep',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Exercise cues
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.exercise.cuesString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Error indicators
        if (_currentErrors.isNotEmpty)
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0.8 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _currentErrors
                    .map((error) => Text(
                          '• $error',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _isDetecting ? _stopDetection : _startDetection,
            backgroundColor: _isDetecting ? Colors.red : Colors.green,
            child: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
          ),
          FloatingActionButton(
            onPressed: _completeRep,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.check),
          ),
          FloatingActionButton(
            onPressed: _resetReps,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  void _completeRep() {
    _handleRepDetection();
  }

  void _resetReps() {
    setState(() {
      _currentRep = 0;
      _currentErrors = [];
      _formScore = 100.0;
    });
  }
}

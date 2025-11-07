import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

import '../../data/models/food_models.dart';
import '../../core/ai/nutrition_detection_notifier.dart';
import '../../core/ai/nutrition_agent.dart';

/// Food Scanner with real camera integration for nutrition logging
class FoodScanner extends ConsumerStatefulWidget {
  const FoodScanner({
    super.key,
    required this.onFoodDetected,
    required this.onError,
  });
  final Function(FoodCatalog) onFoodDetected;
  final Function(String) onError;

  @override
  ConsumerState<FoodScanner> createState() => _FoodScannerState();
}

class _FoodScannerState extends ConsumerState<FoodScanner>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isProcessing = false;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanController.dispose();
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
      }
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        widget.onError('Camera error: $e');
      }
    }
  }

  void _startScanning() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _isScanning = true;
      });
      _scanController.repeat();
      _captureAndAnalyze();
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanController.stop();
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      // Capture image
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Process image for food detection
      await _processFoodImage(imageBytes);
    } catch (e) {
      print('Image capture error: $e');
      widget.onError('Failed to capture image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processFoodImage(Uint8List imageBytes) async {
    try {
      // Convert image to processable format
      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        widget.onError('Failed to process image');
        return;
      }

      // Simulate AI food recognition
      final foodResults = await _recognizeFood(image);

      if (foodResults.isNotEmpty) {
        // Use the first (most confident) result
        final detectedFood = foodResults.first;
        widget.onFoodDetected(detectedFood);

        // Publish detected food to shared notifier for confirmation UI
        try {
          ref.read(nutritionDetectionProvider.notifier).addDetected(
                RecognizedFood(
                  name: detectedFood.name,
                  servingSize:
                      '${detectedFood.servingQty} ${detectedFood.servingUnit ?? ''}',
                  calories:
                      (detectedFood.nutrients['calories'] ?? 0).toDouble(),
                  macros: {
                    'protein_g':
                        (detectedFood.nutrients['protein_g'] ?? 0).toDouble(),
                    'carbs_g':
                        (detectedFood.nutrients['carbs_g'] ?? 0).toDouble(),
                    'fat_g': (detectedFood.nutrients['fat_g'] ?? 0).toDouble(),
                    'fiber_g':
                        (detectedFood.nutrients['fiber_g'] ?? 0).toDouble(),
                  },
                  micronutrients: {},
                  healthBenefits: [],
                  allergens: [],
                  portionEstimate: detectedFood.servingUnit ?? '',
                ),
              );
        } catch (_) {
          // ignore if notifier not available
        }
      } else {
        widget.onError('No food detected in image');
      }
    } catch (e) {
      print('Food recognition error: $e');
      widget.onError('Food recognition failed: $e');
    }
  }

  Future<List<FoodCatalog>> _recognizeFood(img.Image image) async {
    // Simulate AI food recognition with different food types
    final random = DateTime.now().millisecond;
    final foodTypes = _getFoodTypes();
    final selectedFood = foodTypes[random % foodTypes.length];

    // Simulate confidence score
    final confidence = 0.7 + (random % 30) / 100;

    if (confidence < 0.8) {
      return []; // Low confidence, no food detected
    }

    // Build a FoodCatalog from the simulated data and wrap in FoodSearchResult
    final catalog = FoodCatalog(
      id: DateTime.now().millisecondsSinceEpoch,
      source: 'local',
      externalId: null,
      name: selectedFood['name'] as String,
      brand: selectedFood['brand'] as String?,
      servingQty: (selectedFood['servingSize'] as num).toDouble(),
      servingUnit: selectedFood['servingUnit'] as String?,
      nutrients: {
        'calories': (selectedFood['calories'] as num).toDouble(),
        'protein_g': (selectedFood['protein'] as num).toDouble(),
        'carbs_g': (selectedFood['carbs'] as num).toDouble(),
        'fat_g': (selectedFood['fat'] as num).toDouble(),
        'fiber_g': (selectedFood['fiber'] as num).toDouble(),
        'sugar_g': (selectedFood['sugar'] as num).toDouble(),
        'sodium_mg': (selectedFood['sodium'] as num).toDouble(),
      },
      labels: null,
      lang: 'en',
      updatedAt: DateTime.now(),
    );

    return [catalog];
  }

  List<Map<String, dynamic>> _getFoodTypes() {
    return [
      {
        'name': 'Apple',
        'brand': 'Fresh Produce',
        'calories': 95,
        'protein': 0.5,
        'carbs': 25.0,
        'fat': 0.3,
        'fiber': 4.0,
        'sugar': 19.0,
        'sodium': 2.0,
        'servingSize': 1.0,
        'servingUnit': 'medium',
        'imageUrl': 'https://example.com/apple.jpg',
      },
      {
        'name': 'Banana',
        'brand': 'Fresh Produce',
        'calories': 105,
        'protein': 1.3,
        'carbs': 27.0,
        'fat': 0.4,
        'fiber': 3.1,
        'sugar': 14.0,
        'sodium': 1.0,
        'servingSize': 1.0,
        'servingUnit': 'medium',
        'imageUrl': 'https://example.com/banana.jpg',
      },
      {
        'name': 'Chicken Breast',
        'brand': 'Fresh Meat',
        'calories': 165,
        'protein': 31.0,
        'carbs': 0.0,
        'fat': 3.6,
        'fiber': 0.0,
        'sugar': 0.0,
        'sodium': 74.0,
        'servingSize': 100.0,
        'servingUnit': 'g',
        'imageUrl': 'https://example.com/chicken.jpg',
      },
      {
        'name': 'Rice (Cooked)',
        'brand': 'Generic',
        'calories': 130,
        'protein': 2.7,
        'carbs': 28.0,
        'fat': 0.3,
        'fiber': 0.4,
        'sugar': 0.1,
        'sodium': 1.0,
        'servingSize': 100.0,
        'servingUnit': 'g',
        'imageUrl': 'https://example.com/rice.jpg',
      },
      {
        'name': 'Broccoli',
        'brand': 'Fresh Produce',
        'calories': 55,
        'protein': 3.7,
        'carbs': 11.0,
        'fat': 0.6,
        'fiber': 5.1,
        'sugar': 2.6,
        'sodium': 33.0,
        'servingSize': 100.0,
        'servingUnit': 'g',
        'imageUrl': 'https://example.com/broccoli.jpg',
      },
      {
        'name': 'Egg',
        'brand': 'Fresh',
        'calories': 70,
        'protein': 6.0,
        'carbs': 0.6,
        'fat': 5.0,
        'fiber': 0.0,
        'sugar': 0.6,
        'sodium': 70.0,
        'servingSize': 1.0,
        'servingUnit': 'large',
        'imageUrl': 'https://example.com/egg.jpg',
      },
    ];
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

        // Scanning overlay
        if (_isScanning) _buildScanningOverlay(),

        // Processing overlay
        if (_isProcessing) _buildProcessingOverlay(),

        // Controls
        _buildControls(),
      ],
    );
  }

  Widget _buildScanningOverlay() {
    return Stack(
      children: [
        // Dark overlay with scanning area
        Container(
          color: Colors.black.withAlpha((0.5 * 255).round()),
        ),

        // Scanning frame
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner indicators
                ..._buildCornerIndicators(),

                // Scanning line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimation.value * 250,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.green,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Instructions
        Positioned(
          bottom: 150,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Point camera at food item\nKeep steady and well-lit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerIndicators() {
    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withAlpha((0.8 * 255).round()),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing food...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
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
          // Gallery button
          FloatingActionButton(
            onPressed: _openGallery,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.photo_library),
          ),

          // Capture/Stop button
          FloatingActionButton(
            onPressed: _isScanning ? _stopScanning : _startScanning,
            backgroundColor: _isScanning ? Colors.red : Colors.green,
            child: Icon(_isScanning ? Icons.stop : Icons.camera_alt),
          ),

          // Flash toggle
          FloatingActionButton(
            onPressed: _toggleFlash,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.flash_on),
          ),
        ],
      ),
    );
  }

  void _openGallery() {
    // TODO: Implement gallery selection
    widget.onError('Gallery selection not implemented yet');
  }

  void _toggleFlash() {
    if (_cameraController != null) {
      _cameraController!.setFlashMode(
        _cameraController!.value.flashMode == FlashMode.off
            ? FlashMode.torch
            : FlashMode.off,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
// ImagePicker import removed: image selection is now handled by
// FoodImageRecognitionService.pickImage().
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/services/food_image_recognition_service.dart';
import '../../core/services/nutrition_service.dart';

class NutritionLogWithSnapScreen extends ConsumerStatefulWidget {
  const NutritionLogWithSnapScreen({super.key});

  @override
  ConsumerState<NutritionLogWithSnapScreen> createState() =>
      _NutritionLogWithSnapScreenState();
}

class _NutritionLogWithSnapScreenState
    extends ConsumerState<NutritionLogWithSnapScreen> {
  final FoodImageRecognitionService _recognitionService =
      FoodImageRecognitionService();
  // ImagePicker is no longer used directly; image selection is handled by
  // FoodImageRecognitionService.pickImage(). Removed unused field.
  bool _isProcessing = false;
  List<Map<String, dynamic>> _recognizedFoods = [];
  File? _capturedImage;

  Future<void> _captureAndRecognize({bool fromCamera = true}) async {
    try {
      final image = await _recognitionService.pickImage(fromCamera: fromCamera);
      if (image == null) return;

      setState(() {
        _capturedImage = image;
        _isProcessing = true;
      });

      final result = await _recognitionService.recognizeMeal(image);

      // Save to Firestore for real-time tracking
      if (result.isNotEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Not authenticated: inform user and abort saving
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to save recognized meals'),
            ),
          );
          setState(() => _isProcessing = false);
          return;
        }

        final uid = currentUser.uid;
        final fileName =
            'food_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putFile(image);
        final downloadUrl = await storageRef.getDownloadURL();

        await _recognitionService.saveRecognizedMeal(
          foods: result,
          imageUrl: downloadUrl,
        );
      }

      setState(() {
        _recognizedFoods = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logMeal(Map<String, dynamic> food) async {
    try {
      final nutritionService = NutritionService();

      // Prepare meal item
      final mealItem = {
        'food_id': food['id']?.toString(),
        'food_name': food['name'] ?? 'Food',
        'quantity': 1,
        'unit': food['portion'] ?? 'serving',
        'kcal': (food['kcal_estimate'] as num?)?.toInt() ?? 0,
        'protein': (food['protein'] as num?)?.toInt() ?? 0,
        'carbs': (food['carbs'] as num?)?.toInt() ?? 0,
        'fat': (food['fat'] as num?)?.toInt() ?? 0,
      };

      // Log the meal
      await nutritionService.logMeal(
        items: [mealItem],
        photoUrl: _capturedImage?.path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal logged successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log meal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Log Meal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Snap Meal Button
                    AuraCard(
                      variant: AuraCardVariant.nutrition,
                      glow: true,
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGlow,
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Snap Your Meal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Take a photo of your meal and we\'ll recognize it automatically',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _captureAndRecognize(
                                          fromCamera: true),
                                  icon: const Icon(LucideIcons.camera),
                                  label: const Text('Camera'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _captureAndRecognize(
                                          fromCamera: false),
                                  icon: const Icon(LucideIcons.image),
                                  label: const Text('Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Analyzing your meal...',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_recognizedFoods.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Recognized Foods',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._recognizedFoods.map((food) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AuraCard(
                            variant: AuraCardVariant.nutrition,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        food['name'] ?? 'Food',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (food['confidence'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withAlpha((0.2 * 255).round()),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${((food['confidence'] as num) * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (food['portion'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Portion: ${food['portion']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                                if (food['kcal_estimate'] != null &&
                                    (food['kcal_estimate'] as num) > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Est. Calories: ${food['kcal_estimate']} kcal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _logMeal(food),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Log This Food'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

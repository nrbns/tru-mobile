import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/food_image_recognition_service.dart';

/// Provider for FoodImageRecognitionService
final foodImageRecognitionServiceProvider = Provider((ref) => FoodImageRecognitionService());

/// StreamProvider for recognized meals (real-time)
final recognizedMealsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(foodImageRecognitionServiceProvider);
  return service.streamRecognizedMeals();
});


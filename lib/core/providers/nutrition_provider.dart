import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/nutrition_service.dart';

/// Provider for NutritionService
final nutritionServiceProvider = Provider((ref) => NutritionService());

/// StreamProvider for today's meals (real-time)
final todayMealsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return service.streamMeals(limit: 10);
});

/// StreamProvider for all meal logs
final mealLogsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return service.streamMealLogs(limit: 50);
});

/// FutureProvider for today's total calories
final todayCaloriesProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(nutritionServiceProvider);
  return service.getTodayCalories();
});

/// FutureProvider for weekly nutrition summary
final weeklyNutritionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(nutritionServiceProvider);
  return service.getWeeklySummary();
});


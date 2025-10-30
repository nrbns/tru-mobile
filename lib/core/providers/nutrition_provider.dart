import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/nutrition_service.dart';
import 'auth_provider.dart';

/// Provider for NutritionService
final nutritionServiceProvider = Provider((ref) => NutritionService());

/// StreamProvider for today's meals (real-time)
final todayMealsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    // Not signed in — return an empty stream so UI can show an empty state instead of erroring
    return Stream.value(<Map<String, dynamic>>[]);
  }
  final service = ref.watch(nutritionServiceProvider);
  return service.streamMeals(limit: 10);
});

/// StreamProvider for all meal logs
final mealLogsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Stream.value(<Map<String, dynamic>>[]);
  }
  final service = ref.watch(nutritionServiceProvider);
  return service.streamMealLogs(limit: 50);
});

/// FutureProvider for today's total calories
final todayCaloriesProvider = FutureProvider<int>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return 0;
  final service = ref.watch(nutritionServiceProvider);
  return service.getTodayCalories();
});

/// FutureProvider for weekly nutrition summary
final weeklyNutritionProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return <String, dynamic>{};
  final service = ref.watch(nutritionServiceProvider);
  return service.getWeeklySummary();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meal_plan_service.dart';

final mealPlanServiceProvider = Provider((ref) => MealPlanService());

final activeMealPlanProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(mealPlanServiceProvider).getActiveMealPlan();
});

final todayMealsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(mealPlanServiceProvider).getTodayMeals();
});

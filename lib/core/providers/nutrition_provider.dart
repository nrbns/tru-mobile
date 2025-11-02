import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

/// StreamProvider for today's total calories (real-time)
final todayCaloriesProvider = StreamProvider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return Stream.value(0);
  final service = ref.watch(nutritionServiceProvider);
  // Stream calories by watching meal logs
  return service.streamMealLogs(limit: 100).map((logs) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    int total = 0;
    for (final log in logs) {
      final ts = log['at'];
      if (ts == null) continue;
      DateTime? logDate;
      if (ts is Timestamp) {
        logDate = ts.toDate();
      }
      if (logDate != null && logDate.isAfter(todayStart)) {
        final totalMap = log['total'] as Map<String, dynamic>? ?? {};
        total += totalMap['kcal'] as int? ?? 0;
      }
    }
    return total;
  });
});

/// FutureProvider for weekly nutrition summary
final weeklyNutritionProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return <String, dynamic>{};
  final service = ref.watch(nutritionServiceProvider);
  return service.getWeeklySummary();
});

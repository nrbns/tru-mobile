import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/activity_tracking_service.dart';

final activityTrackingServiceProvider =
    Provider((ref) => ActivityTrackingService());

final todayActivityProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(activityTrackingServiceProvider).streamTodayActivity();
});

final activityHistoryProvider =
    StreamProvider.family<List<Map<String, dynamic>>, int>((ref, days) {
  return ref
      .watch(activityTrackingServiceProvider)
      .streamActivityHistory(days: days);
});

final activityStreakProvider =
    FutureProvider.family<int, int>((ref, minSteps) async {
  return ref
      .watch(activityTrackingServiceProvider)
      .getActivityStreak(minSteps: minSteps);
});

final weeklyActivitySummaryProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(activityTrackingServiceProvider).getWeeklyActivitySummary();
});

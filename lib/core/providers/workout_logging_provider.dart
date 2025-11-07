import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/workout_logging_service.dart';

/// Provider for WorkoutLoggingService
final workoutLoggingServiceProvider =
    Provider((ref) => WorkoutLoggingService());

/// StreamProvider for workout logs (real-time)
final workoutLogsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(workoutLoggingServiceProvider);
  return service.streamWorkoutLogs();
});

/// StreamProvider for today's workouts (real-time)
final todayWorkoutsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(workoutLoggingServiceProvider);
  return service.streamTodayWorkouts();
});

/// FutureProvider for workout stats
final workoutStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, days) async {
  final service = ref.watch(workoutLoggingServiceProvider);
  return service.getWorkoutStats(days: days);
});

/// FutureProvider for exercise progress
final exerciseProgressProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(workoutLoggingServiceProvider);
  final exerciseId = params['exercise_id'] as String;
  final days = params['days'] as int? ?? 30;
  return service.getExerciseProgress(exerciseId: exerciseId, days: days);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/workout_generation_service.dart';

/// Provider for WorkoutGenerationService
final workoutGenerationServiceProvider = Provider((ref) => WorkoutGenerationService());

/// FutureProvider for workout history
final workoutHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(workoutGenerationServiceProvider);
  return service.getWorkoutHistory();
});


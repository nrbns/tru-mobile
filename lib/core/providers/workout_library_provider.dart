import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/exercise_library_service.dart';
import '../services/enhanced_workout_generator_service.dart';

/// Provider for ExerciseLibraryService
final exerciseLibraryServiceProvider =
    Provider((ref) => ExerciseLibraryService());

/// Provider for EnhancedWorkoutGeneratorService
final enhancedWorkoutGeneratorProvider =
    Provider((ref) => EnhancedWorkoutGeneratorService());

/// StreamProvider for exercises
final exercisesStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return service.streamExercises(
    muscleGroups: params['muscleGroups'] as List<String>?,
    equipment: params['equipment'] as List<String>?,
    limit: params['limit'] as int? ?? 100,
  );
});

/// FutureProvider for exercises with filters
final exercisesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return service.getExercises(
    muscleGroups: params['muscleGroups'] as List<String>?,
    equipment: params['equipment'] as List<String>?,
    difficulty: params['difficulty'] as List<String>?,
    compoundOnly: params['compoundOnly'] as bool?,
    isolationOnly: params['isolationOnly'] as bool?,
    searchQuery: params['searchQuery'] as String?,
    limit: params['limit'] as int? ?? 100,
  );
});

/// FutureProvider for muscle groups
final muscleGroupsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return service.getAvailableMuscleGroups();
});

/// FutureProvider for equipment types
final equipmentTypesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return service.getAvailableEquipment();
});

/// FutureProvider for workout history
final workoutHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final service = ref.watch(enhancedWorkoutGeneratorProvider);
  return service.getWorkoutHistory(limit: limit);
});

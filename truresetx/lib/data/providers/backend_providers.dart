import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/supabase_edge_functions.dart';
import '../models/food_models.dart';
import '../models/exercise_models.dart';
import '../models/workout_models.dart';
import '../models/mood_models.dart';
import '../models/spiritual_models.dart';

/// Food-related providers
final foodSearchProvider =
    FutureProvider.family<FoodSearchResult, String>((ref, query) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.searchFoods(query: query);
  return FoodSearchResult.fromJson(response);
});

final dailyNutritionProvider =
    FutureProvider.family<DailyNutrition, String?>((ref, date) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getDailyNutrition(date: date);
  return DailyNutrition.fromJson(response);
});

final foodScanProvider =
    FutureProvider.family<FoodScanResult, Map<String, dynamic>>(
        (ref, scanData) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.scanFood(
    imageUrl: scanData['imageUrl'] as String?,
    barcode: scanData['barcode'] as String?,
    notes: scanData['notes'] as String?,
  );
  return FoodScanResult.fromJson(response);
});

/// Exercise-related providers
final exercisesProvider =
    FutureProvider.family<ExerciseList, String?>((ref, muscle) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getExercises(muscle: muscle);
  return ExerciseList.fromJson(response);
});

final exerciseCategoriesProvider =
    FutureProvider<List<ExerciseCategory>>((ref) async {
  final exercises = await ref.watch(exercisesProvider(null).future);

  // Group exercises by muscle groups
  final categories = <String, List<Exercise>>{};
  for (final exercise in exercises.exercises) {
    final category = _getMuscleGroupCategory(exercise.primaryMuscle);
    categories.putIfAbsent(category, () => []).add(exercise);
  }

  return categories.entries.map((entry) {
    return ExerciseCategory(
      name: entry.key,
      muscles: _getMusclesForCategory(entry.key),
      exercises: entry.value,
    );
  }).toList();
});

String _getMuscleGroupCategory(String muscle) {
  const upperBodyMuscles = [
    'chest',
    'anterior_deltoid',
    'posterior_deltoid',
    'lateral_deltoid',
    'triceps',
    'biceps',
    'forearms',
    'lats',
    'rhomboids',
    'traps'
  ];
  const lowerBodyMuscles = [
    'quadriceps',
    'hamstrings',
    'glutes',
    'calves',
    'hip_flexors',
    'adductors',
    'abductors'
  ];
  const coreMuscles = [
    'core',
    'abs',
    'obliques',
    'lower_back',
    'erector_spinae'
  ];

  if (upperBodyMuscles.contains(muscle)) return 'Upper Body';
  if (lowerBodyMuscles.contains(muscle)) return 'Lower Body';
  if (coreMuscles.contains(muscle)) return 'Core';
  return 'Other';
}

List<String> _getMusclesForCategory(String category) {
  switch (category) {
    case 'Upper Body':
      return [
        'chest',
        'anterior_deltoid',
        'posterior_deltoid',
        'lateral_deltoid',
        'triceps',
        'biceps',
        'forearms',
        'lats',
        'rhomboids',
        'traps'
      ];
    case 'Lower Body':
      return [
        'quadriceps',
        'hamstrings',
        'glutes',
        'calves',
        'hip_flexors',
        'adductors',
        'abductors'
      ];
    case 'Core':
      return ['core', 'abs', 'obliques', 'lower_back', 'erector_spinae'];
    default:
      return [];
  }
}

/// Workout-related providers
final todaysWorkoutProvider = FutureProvider<Workout?>((ref) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getTodaysWorkout();
  if (response['workout'] != null) {
    return Workout.fromJson(response['workout']);
  }
  return null;
});

final workoutSessionProvider =
    StateNotifierProvider<WorkoutSessionNotifier, WorkoutSession?>((ref) {
  return WorkoutSessionNotifier();
});

class WorkoutSessionNotifier extends StateNotifier<WorkoutSession?> {
  WorkoutSessionNotifier() : super(null);

  void startWorkout(Workout workout) {
    state = WorkoutSession(
      workout: workout,
      setLogs: [],
      startTime: DateTime.now(),
    );
  }

  void addSetLog(SetLog setLog) {
    if (state != null) {
      state = WorkoutSession(
        workout: state!.workout,
        setLogs: [...state!.setLogs, setLog],
        startTime: state!.startTime,
        endTime: state!.endTime,
        totalDuration: state!.totalDuration,
        caloriesBurned: state!.caloriesBurned,
        notes: state!.notes,
      );
    }
  }

  void endWorkout({String? notes}) {
    if (state != null) {
      final endTime = DateTime.now();
      final duration = state!.startTime != null
          ? endTime.difference(state!.startTime!).inMinutes
          : 0;

      state = WorkoutSession(
        workout: state!.workout,
        setLogs: state!.setLogs,
        startTime: state!.startTime,
        endTime: endTime,
        totalDuration: duration,
        caloriesBurned: state!.caloriesBurned,
        notes: notes,
      );
    }
  }

  void reset() {
    state = null;
  }
}

/// Mood-related providers
final who5ItemsProvider = FutureProvider<List<Who5Item>>((ref) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getWho5Items();
  return (response['items'] as List)
      .map((item) => Who5Item.fromJson(item))
      .toList();
});

final moodSummaryProvider =
    FutureProvider.family<MoodSummary, String?>((ref, week) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getMoodSummary(week: week);
  return MoodSummary.fromJson(response);
});

final moodLogsProvider =
    StateNotifierProvider<MoodLogsNotifier, List<MoodLog>>((ref) {
  return MoodLogsNotifier();
});

class MoodLogsNotifier extends StateNotifier<List<MoodLog>> {
  MoodLogsNotifier() : super([]);

  void addMoodLog(MoodLog moodLog) {
    state = [...state, moodLog];
  }

  void updateMoodLog(MoodLog moodLog) {
    state = state.map((log) => log.id == moodLog.id ? moodLog : log).toList();
  }

  /// Add a mood log or update existing one with same id. Useful for realtime
  /// inserts/updates coming from supabase so we don't create duplicates.
  void addOrUpdateMoodLog(MoodLog moodLog) {
    final index = state.indexWhere((l) => l.id == moodLog.id);
    if (index == -1) {
      // prepend new logs so recent entries appear first in UI
      state = [moodLog, ...state];
    } else {
      final copy = [...state];
      copy[index] = moodLog;
      state = copy;
    }
  }

  void removeMoodLog(int id) {
    state = state.where((log) => log.id != id).toList();
  }

  MoodLog? getMoodLogForDate(DateTime date) {
    try {
      return state.firstWhere((log) =>
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day);
    } catch (e) {
      return null;
    }
  }
}

/// Spiritual-related providers
final gitaVerseProvider =
    FutureProvider.family<GitaVerse, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getGitaVerse(
    chapter: params['chapter'] as int,
    verse: params['verse'] as int,
    language: params['language'] as String? ?? 'en',
  );
  return GitaVerse.fromJson(response);
});

final dailyWisdomProvider = FutureProvider<WisdomItem>((ref) async {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  final response = await service.getDailyWisdom();
  return WisdomItem.fromJson(response);
});

/// Realtime-like streams (polled) for spiritual content; these are simple
/// stream providers that poll the edge functions so UI can subscribe and
/// update when new items appear. Replace with true realtime subscriptions
/// if you wire Supabase Realtime or Firestore snapshots.
final gitaVerseStreamProvider =
    StreamProvider.family<GitaVerse, Map<String, int>>((ref, params) {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  Stream<GitaVerse> stream() async* {
    // Immediate first fetch
    try {
      final resp = await service.getGitaVerse(
        chapter: params['chapter'] ?? 1,
        verse: params['verse'] ?? 1,
        language: 'en',
      );
      yield GitaVerse.fromJson(resp);
    } catch (_) {
      // ignore and continue polling
    }
    // Poll loop
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      try {
        final resp = await service.getGitaVerse(
          chapter: params['chapter'] ?? 1,
          verse: params['verse'] ?? 1,
          language: 'en',
        );
        yield GitaVerse.fromJson(resp);
      } catch (_) {
        // swallow and retry next tick
      }
    }
  }

  return stream();
});

final wisdomStreamProvider = StreamProvider<WisdomItem>((ref) {
  final service = ref.watch(supabaseEdgeFunctionsProvider);
  Stream<WisdomItem> stream() async* {
    try {
      final resp = await service.getDailyWisdom();
      yield WisdomItem.fromJson(resp);
    } catch (_) {}
    while (true) {
      await Future.delayed(const Duration(seconds: 60));
      try {
        final resp = await service.getDailyWisdom();
        yield WisdomItem.fromJson(resp);
      } catch (_) {}
    }
  }

  return stream();
});

final spiritualProgressStreamProvider =
    StreamProvider<SpiritualProgress?>((ref) {
  Stream<SpiritualProgress?> stream() async* {
    // Placeholder: edge function for progress isn't implemented yet.
    // Yield null initially and poll so consumers can refresh when an endpoint exists.
    yield null;
    while (true) {
      await Future.delayed(const Duration(seconds: 15));
      try {
        // If you add an endpoint like getSpiritualProgress, call it here.
        yield null;
      } catch (_) {
        yield null;
      }
    }
  }

  return stream();
});

final spiritualProgressProvider =
    StateNotifierProvider<SpiritualProgressNotifier, SpiritualProgress?>((ref) {
  return SpiritualProgressNotifier();
});

class SpiritualProgressNotifier extends StateNotifier<SpiritualProgress?> {
  SpiritualProgressNotifier() : super(null);

  void updateProgress(SpiritualProgress progress) {
    state = progress;
  }

  void incrementStreak() {
    if (state != null) {
      state = SpiritualProgress(
        period: state!.period,
        totalWisdomItems: state!.totalWisdomItems,
        completedItems: state!.completedItems,
        totalVerses: state!.totalVerses,
        readVerses: state!.readVerses,
        streak: state!.streak + 1,
        insights: state!.insights,
      );
    }
  }

  void completeWisdomItem() {
    if (state != null) {
      state = SpiritualProgress(
        period: state!.period,
        totalWisdomItems: state!.totalWisdomItems,
        completedItems: state!.completedItems + 1,
        totalVerses: state!.totalVerses,
        readVerses: state!.readVerses,
        streak: state!.streak,
        insights: state!.insights,
      );
    }
  }

  void readVerse() {
    if (state != null) {
      state = SpiritualProgress(
        period: state!.period,
        totalWisdomItems: state!.totalWisdomItems,
        completedItems: state!.completedItems,
        totalVerses: state!.totalVerses,
        readVerses: state!.readVerses + 1,
        streak: state!.streak,
        insights: state!.insights,
      );
    }
  }
}

/// Combined providers for dashboard
final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final todaysWorkout = await ref.watch(todaysWorkoutProvider.future);
  final dailyNutrition = await ref.watch(dailyNutritionProvider(null).future);
  final moodLogs = ref.watch(moodLogsProvider);
  final dailyWisdom = await ref.watch(dailyWisdomProvider.future);

  return {
    'workout': todaysWorkout,
    'nutrition': dailyNutrition,
    'mood': moodLogs.isNotEmpty ? moodLogs.last : null,
    'wisdom': dailyWisdom,
  };
});

/// Search providers
final foodSearchQueryProvider = StateProvider<String>((ref) => '');
final exerciseMuscleFilterProvider = StateProvider<String?>((ref) => null);
final moodWeekFilterProvider = StateProvider<String?>((ref) => null);

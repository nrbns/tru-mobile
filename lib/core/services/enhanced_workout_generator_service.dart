import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_library_service.dart';
import 'mood_service.dart';
import 'spiritual_service.dart';

/// Enhanced Workout Generator Service (MuscleWiki-style)
/// Combines exercise library with AI generation
/// Includes mood/spiritual state adaptation
class EnhancedWorkoutGeneratorService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ExerciseLibraryService _exerciseLibrary = ExerciseLibraryService();
  final MoodService _moodService = MoodService();
  final SpiritualService _spiritualService = SpiritualService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError(
          'EnhancedWorkoutGeneratorService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Generate workout with comprehensive parameters
  Future<Map<String, dynamic>> generateWorkout({
    required String
        goal, // 'muscle_gain', 'weight_loss', 'general_fitness', 'stress_relief'
    required List<String> equipment, // ['bodyweight', 'dumbbells', etc.]
    required int durationMinutes,
    List<String>? targetMuscleGroups,
    int? exactExerciseCount,
    String? difficulty, // 'beginner', 'intermediate', 'advanced'
    bool? compoundOnly,
    bool? isolationOnly,
    bool? includeMoodAdaptation = true,
    bool? includeSpiritIntegration = true,
  }) async {
    try {
      // Get user context for mood/spiritual adaptation
      Map<String, dynamic>? userContext;
      if (includeMoodAdaptation == true || includeSpiritIntegration == true) {
        userContext = await _getUserContext();
      }

      // Get exercises from library based on filters
      final exercises = await _exerciseLibrary.getExercises(
        muscleGroups: targetMuscleGroups,
        equipment: equipment,
        difficulty: difficulty != null ? [difficulty] : null,
        compoundOnly: compoundOnly,
        isolationOnly: isolationOnly,
      );

      if (exercises.isEmpty) {
        throw Exception('No exercises found matching criteria');
      }

      // Prepare generation parameters
      final params = {
        'goal': goal,
        'equipment': equipment,
        'duration_minutes': durationMinutes,
        'target_muscle_groups': targetMuscleGroups ?? [],
        'available_exercises': exercises
            .take(50)
            .map((e) => {
                  'id': e['id'],
                  'name': e['name'],
                  'muscle_groups': e['muscle_groups'],
                  'equipment': e['equipment'],
                  'difficulty': e['difficulty'],
                  'is_compound': e['is_compound'],
                  'instructions': e['instructions'],
                })
            .toList(),
        'exact_exercise_count': exactExerciseCount,
        'user_context': userContext,
      };

      // Call Cloud Function for AI generation
      final callable = _functions.httpsCallable('generateEnhancedWorkout');
      final result = await callable.call(params);

      final workout = Map<String, dynamic>.from(result.data);

      // Save generated workout
      await _saveGeneratedWorkout(workout);

      return workout;
    } catch (e) {
      throw Exception('Failed to generate workout: $e');
    }
  }

  /// Get user context for adaptive workout generation
  Future<Map<String, dynamic>> _getUserContext() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError(
          'EnhancedWorkoutGeneratorService: no authenticated user');
    }
    final uid = currentUser.uid;

    // Get today's mood
    final recentMoods = await _moodService.getMoodLogs(limit: 1);
    final todayMood = recentMoods.isNotEmpty ? recentMoods.first.score : 5;

    // Get spiritual streak
    final spiritualStreak = await _spiritualService.getStreakDays();

    // Get recent workout completion
    final recentWorkoutsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_logs')
        .orderBy('completed_at', descending: true)
        .limit(1)
        .get();

    DateTime? lastCompletedAt;
    if (recentWorkoutsSnapshot.docs.isNotEmpty) {
      final raw =
          recentWorkoutsSnapshot.docs.first.data() as Map<String, dynamic>?;
      final ts = raw?['completed_at'] as Timestamp?;
      lastCompletedAt = ts?.toDate();
    }

    final daysSinceLastWorkout = lastCompletedAt != null
        ? DateTime.now().difference(lastCompletedAt).inDays
        : 999;

    return {
      'mood_score': todayMood,
      'spiritual_streak_days': spiritualStreak,
      'days_since_last_workout': daysSinceLastWorkout,
      'has_low_energy': todayMood < 4 || daysSinceLastWorkout > 3,
      'needs_recovery': daysSinceLastWorkout == 1, // Just worked out yesterday
    };
  }

  /// Save generated workout to Firestore
  Future<void> _saveGeneratedWorkout(Map<String, dynamic> workout) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError(
          'EnhancedWorkoutGeneratorService: no authenticated user');
    }
    final uid = currentUser.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_plans')
        .add({
      ...workout,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'generated',
    });
  }

  /// Generate workout based on body map selection
  Future<Map<String, dynamic>> generateFromBodyMap({
    required List<String> selectedMuscleGroups,
    required List<String> equipment,
    required int durationMinutes,
    String goal = 'general_fitness',
    int? exactExerciseCount,
  }) async {
    return generateWorkout(
      goal: goal,
      equipment: equipment,
      durationMinutes: durationMinutes,
      targetMuscleGroups: selectedMuscleGroups,
      exactExerciseCount: exactExerciseCount,
    );
  }

  /// Generate adaptive workout based on mood/spiritual state
  Future<Map<String, dynamic>> generateAdaptiveWorkout({
    required List<String> equipment,
    int durationMinutes = 30,
    int? exactExerciseCount,
  }) async {
    final context = await _getUserContext();

    // Adapt based on user state
    String goal = 'general_fitness';
    String? difficulty;
    bool? compoundOnly;

    if (context['has_low_energy'] == true) {
      goal = 'stress_relief';
      difficulty = 'beginner';
      compoundOnly = false; // Prefer lighter, isolation movements
    } else if (context['needs_recovery'] == true) {
      goal = 'mobility';
      difficulty = 'beginner';
    } else if (context['mood_score'] >= 7) {
      // High mood = can handle intense workout
      goal = 'muscle_gain';
      difficulty = 'intermediate';
      compoundOnly = true;
    }

    return generateWorkout(
      goal: goal,
      equipment: equipment,
      durationMinutes: durationMinutes,
      exactExerciseCount: exactExerciseCount,
      difficulty: difficulty,
      compoundOnly: compoundOnly,
      includeMoodAdaptation: true,
      includeSpiritIntegration: true,
    );
  }

  /// Get workout history
  Future<List<Map<String, dynamic>>> getWorkoutHistory({int limit = 20}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError(
          'EnhancedWorkoutGeneratorService: no authenticated user');
    }
    final uid = currentUser.uid;
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_logs')
        .orderBy('completed_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Log workout completion with sets, reps, weights
  Future<void> logWorkout({
    required String workoutPlanId,
    required List<Map<String, dynamic>>
        exercisesCompleted, // [{exercise_id, sets, reps, weight, notes}]
    int? moodBefore,
    int? moodAfter,
    String? notes,
  }) async {
    final uid = _requireUid();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_logs')
        .add({
      'workout_plan_id': workoutPlanId,
      'exercises_completed': exercisesCompleted,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'notes': notes,
      'completed_at': FieldValue.serverTimestamp(),
    });

    // Update mood if provided
    if (moodAfter != null) {
      await _moodService.logMood(
        score: moodAfter,
        emotions: ['energized', 'accomplished'],
        note: 'Post-workout mood',
      );
    }
  }
}

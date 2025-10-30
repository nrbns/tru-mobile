import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Full Workout Logging Service - Sets, Reps, Weights, Real-time Updates
class WorkoutLoggingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('WorkoutLoggingService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _workoutLogsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('workout_logs');
  }

  /// Log workout with detailed sets, reps, weights
  Future<String> logWorkout({
    required String workoutPlanId,
    required List<WorkoutExercise> exercises,
    int? durationMinutes,
    int? moodBefore,
    int? moodAfter,
    int? energyLevel, // 1-10
    String? notes,
    DateTime? completedAt,
  }) async {
    final now = completedAt ?? DateTime.now();

    // Calculate totals
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0; // total weight * reps

    for (final exercise in exercises) {
      totalSets += exercise.sets.length;
      for (final set in exercise.sets) {
        totalReps += set.reps;
        totalVolume += (set.weight ?? 0) * set.reps;
      }
    }

    final docRef = await _workoutLogsRef.add({
      'workout_plan_id': workoutPlanId,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'duration_minutes': durationMinutes,
      'total_sets': totalSets,
      'total_reps': totalReps,
      'total_volume': totalVolume,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'energy_level': energyLevel,
      'notes': notes,
      'completed_at': FieldValue.serverTimestamp(),
      'timestamp': Timestamp.fromDate(now),
      'date':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    });

    // Update today's workout status
    await _updateTodayWorkoutStatus();

    return docRef.id;
  }

  /// Update today's workout status in today collection
  Future<void> _updateTodayWorkoutStatus() async {
    final uid = _requireUid();
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Get today's workout count
    final todayWorkouts =
        await _workoutLogsRef.where('date', isEqualTo: dateKey).get();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .doc(dateKey)
        .set({
      'workouts': {
        'done': todayWorkouts.docs.length,
        'target': 1, // Default target
        'updated_at': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  /// Stream workout logs for real-time updates
  Stream<List<Map<String, dynamic>>> streamWorkoutLogs({int limit = 30}) {
    return _workoutLogsRef
        .orderBy('completed_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Stream today's workouts
  Stream<List<Map<String, dynamic>>> streamTodayWorkouts() {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _workoutLogsRef
        .where('date', isEqualTo: dateKey)
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get workout log by ID
  Future<Map<String, dynamic>?> getWorkoutLog(String logId) async {
    final doc = await _workoutLogsRef.doc(logId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Get exercise progress over time
  Future<List<Map<String, dynamic>>> getExerciseProgress({
    required String exerciseId,
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final startTimestamp = Timestamp.fromDate(startDate);

    final snapshot = await _workoutLogsRef
        .where('completed_at', isGreaterThanOrEqualTo: startTimestamp)
        .orderBy('completed_at', descending: false)
        .get();

    final progress = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final exercises = data['exercises'] as List? ?? [];

      for (final exData in exercises) {
        final exMap = exData as Map<String, dynamic>;
        if (exMap['exercise_id'] == exerciseId) {
          final sets = exMap['sets'] as List? ?? [];
          double maxWeight = 0;
          int totalReps = 0;
          double totalVolume = 0;

          for (final setData in sets) {
            final setMap = setData as Map<String, dynamic>;
            final weight = (setMap['weight'] as num?)?.toDouble() ?? 0;
            final reps = setMap['reps'] as int? ?? 0;

            if (weight > maxWeight) maxWeight = weight;
            totalReps += reps;
            totalVolume += weight * reps;
          }

          progress.add({
            'date': (data['completed_at'] as Timestamp?)?.toDate(),
            'max_weight': maxWeight,
            'total_reps': totalReps,
            'total_volume': totalVolume,
            'sets_count': sets.length,
          });
        }
      }
    }

    return progress;
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final startTimestamp = Timestamp.fromDate(startDate);

    final snapshot = await _workoutLogsRef
        .where('completed_at', isGreaterThanOrEqualTo: startTimestamp)
        .get();

    int totalWorkouts = snapshot.docs.length;
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;
    int totalMinutes = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      totalSets += data['total_sets'] as int? ?? 0;
      totalReps += data['total_reps'] as int? ?? 0;
      totalVolume += (data['total_volume'] as num?)?.toDouble() ?? 0;
      totalMinutes += data['duration_minutes'] as int? ?? 0;
    }

    return {
      'total_workouts': totalWorkouts,
      'total_sets': totalSets,
      'total_reps': totalReps,
      'total_volume': totalVolume,
      'total_minutes': totalMinutes,
      'avg_workouts_per_week': (totalWorkouts / (days / 7)).toStringAsFixed(1),
      'avg_volume_per_workout': totalWorkouts > 0
          ? (totalVolume / totalWorkouts).toStringAsFixed(1)
          : '0',
    };
  }

  /// Delete workout log
  Future<void> deleteWorkoutLog(String logId) async {
    await _workoutLogsRef.doc(logId).delete();
    await _updateTodayWorkoutStatus();
  }
}

/// Workout Exercise Model
class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final List<WorkoutSet> sets;
  final String? notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets.map((s) => s.toMap()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exercise_id'] ?? '',
      exerciseName: map['exercise_name'] ?? '',
      sets: (map['sets'] as List?)
              ?.map((s) => WorkoutSet.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'],
    );
  }
}

/// Workout Set Model
class WorkoutSet {
  final int reps;
  final double? weight; // null for bodyweight
  final int? restSeconds;
  final bool completed;
  final String? notes;

  WorkoutSet({
    required this.reps,
    this.weight,
    this.restSeconds,
    this.completed = true,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
      'rest_seconds': restSeconds,
      'completed': completed,
      'notes': notes,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      reps: map['reps'] ?? 0,
      weight: (map['weight'] as num?)?.toDouble(),
      restSeconds: map['rest_seconds'] as int?,
      completed: map['completed'] ?? true,
      notes: map['notes'],
    );
  }
}

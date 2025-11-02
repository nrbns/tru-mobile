import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Body Engine - Fitness adaptation based on biometrics and activity
class BodyEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final String? _uid;

  BodyEngine(this._db, this._auth) : _uid = _auth.currentUser?.uid;

  /// Get current body state from wearables and logs
  Future<BodyState> getCurrentBodyState() async {
    if (_uid == null) {
      return BodyState.empty();
    }

    // Get today's data
    final todayRef = _db.collection('users').doc(_uid).collection('today').doc('current');
    final todaySnap = await todayRef.get();
    final todayData = todaySnap.data() ?? {};

    // Get recent workout history
    final workouts = await _getRecentWorkouts(days: 7);

    // Calculate metrics
    final caloriesBurned = (todayData['calories_burned'] as num?)?.toDouble() ?? 0.0;
    final caloriesConsumed = (todayData['calories_consumed'] as num?)?.toDouble() ?? 0.0;
    final steps = (todayData['steps'] as num?)?.toInt() ?? 0;
    final waterMl = (todayData['water_ml'] as num?)?.toInt() ?? 0;

    // Calculate recovery status
    final lastWorkout = workouts.isNotEmpty ? workouts.first : null;
    final hoursSinceWorkout = lastWorkout != null
        ? DateTime.now().difference(lastWorkout['completedAt'] as DateTime).inHours
        : 999;

    final recoveryStatus = _calculateRecovery(hoursSinceWorkout, workouts.length);

    return BodyState(
      caloriesBurned: caloriesBurned,
      caloriesConsumed: caloriesConsumed,
      steps: steps,
      waterMl: waterMl,
      recoveryStatus: recoveryStatus,
      lastWorkoutHoursAgo: hoursSinceWorkout == 999 ? null : hoursSinceWorkout,
      workoutFrequency: workouts.length,
    );
  }

  /// Suggest workout adaptation based on body state
  Future<WorkoutAdaptation> suggestWorkoutAdaptation(BodyState bodyState) async {
    String recommendation = 'moderate';
    String reason = '';
    double intensity = 0.6;

    // Recovery-based adaptation
    if (bodyState.recoveryStatus == RecoveryStatus.needRest) {
      recommendation = 'light';
      reason = 'Your body needs recovery. Consider yoga or stretching.';
      intensity = 0.3;
    } else if (bodyState.recoveryStatus == RecoveryStatus.recovered) {
      recommendation = 'intense';
      reason = 'You\'re fully recovered. Great time for a challenging workout!';
      intensity = 0.8;
    }

    // Energy-based adaptation
    if (bodyState.caloriesConsumed < bodyState.caloriesBurned * 0.7) {
      recommendation = 'light';
      reason = 'Low energy from insufficient nutrition. Focus on light movement.';
      intensity = 0.4;
    }

    // Weekly volume check
    if (bodyState.workoutFrequency >= 6) {
      recommendation = 'rest';
      reason = 'High weekly volume detected. Rest day recommended.';
      intensity = 0.0;
    }

    return WorkoutAdaptation(
      recommendation: recommendation,
      reason: reason,
      suggestedIntensity: intensity,
      suggestedDuration: _getSuggestedDuration(recommendation),
    );
  }

  RecoveryStatus _calculateRecovery(int hoursSinceWorkout, int weeklyFrequency) {
    if (hoursSinceWorkout < 24) return RecoveryStatus.needRest;
    if (hoursSinceWorkout < 48) return RecoveryStatus.recovering;
    if (hoursSinceWorkout >= 48 && weeklyFrequency < 4) return RecoveryStatus.recovered;
    return RecoveryStatus.maintaining;
  }

  int _getSuggestedDuration(String recommendation) {
    switch (recommendation) {
      case 'rest':
        return 0;
      case 'light':
        return 20;
      case 'moderate':
        return 45;
      case 'intense':
        return 60;
      default:
        return 30;
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentWorkouts({int days = 7}) async {
    if (_uid == null) return [];
    final since = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('workout_sessions')
        .where('completedAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'completedAt': (data['completedAt'] as Timestamp?)?.toDate(),
      };
    }).toList();
  }
}

class BodyState {
  final double caloriesBurned;
  final double caloriesConsumed;
  final int steps;
  final int waterMl;
  final RecoveryStatus recoveryStatus;
  final int? lastWorkoutHoursAgo;
  final int workoutFrequency;

  BodyState({
    required this.caloriesBurned,
    required this.caloriesConsumed,
    required this.steps,
    required this.waterMl,
    required this.recoveryStatus,
    this.lastWorkoutHoursAgo,
    required this.workoutFrequency,
  });

  factory BodyState.empty() {
    return BodyState(
      caloriesBurned: 0,
      caloriesConsumed: 0,
      steps: 0,
      waterMl: 0,
      recoveryStatus: RecoveryStatus.unknown,
      workoutFrequency: 0,
    );
  }
}

enum RecoveryStatus {
  needRest,
  recovering,
  recovered,
  maintaining,
  unknown,
}

class WorkoutAdaptation {
  final String recommendation; // 'rest', 'light', 'moderate', 'intense'
  final String reason;
  final double suggestedIntensity; // 0.0 to 1.0
  final int suggestedDuration; // minutes

  WorkoutAdaptation({
    required this.recommendation,
    required this.reason,
    required this.suggestedIntensity,
    required this.suggestedDuration,
  });
}


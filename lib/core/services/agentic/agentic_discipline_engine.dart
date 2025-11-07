import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/telemetry_channel.dart';

/// Discipline Engine: Accountability, gamification, adaptive triggers, consequences
class AgenticDisciplineEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final TelemetryChannel _telemetry;

  AgenticDisciplineEngine(this._db, this._auth) : _telemetry = TelemetryChannel();

  String? get _uid => _auth.currentUser?.uid;

  /// Track missed sessions and trigger adaptive responses
  Future<DisciplineResponse> checkDisciplineStatus() async {
    if (_uid == null) return DisciplineResponse(mode: DisciplineMode.gentle, message: '');

    // Count missed workouts in last 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final missedWorkouts = await _db
        .collection('users')
        .doc(_uid)
        .collection('workout_sessions')
        .where('scheduled_at', isGreaterThan: sevenDaysAgo.millisecondsSinceEpoch)
        .where('completed', isEqualTo: false)
        .get();

    final missedCount = missedWorkouts.docs.length;

    // Adaptive discipline triggers
    if (missedCount >= 3) {
      return DisciplineResponse(
        mode: DisciplineMode.strict,
        message: 'You\'ve missed 3 sessions. Let\'s get back on track with an accountability check-in.',
        actions: [
          DisciplineAction(
            type: 'challenge',
            title: 'Complete a 15-min workout now',
            reward: 'Restored streak',
            penalty: 'Extended recovery period',
          ),
          DisciplineAction(
            type: 'reflection',
            title: 'Why did you skip? Let\'s talk.',
            reward: 'Personalized plan',
            penalty: null,
          ),
        ],
      );
    }

    if (missedCount == 2) {
      return DisciplineResponse(
        mode: DisciplineMode.push,
        message: 'Two missed sessions detected. I\'m here to help you stay consistent.',
        actions: [
          DisciplineAction(
            type: 'motivation',
            title: 'Reminder: You\'re stronger than you think',
            reward: 'Motivational message',
            penalty: null,
          ),
        ],
      );
    }

    return DisciplineResponse(mode: DisciplineMode.gentle, message: 'You\'re doing great!');
  }

  /// Generate auto-execution goals based on patterns
  Future<List<AutoGoal>> generateAutoGoals({
    required Map<String, dynamic> userPatterns,
    required double currentEnergy,
    required double stressLevel,
  }) async {
    final goals = <AutoGoal>[];

    // If user always skips morning workouts, suggest afternoon
    if (userPatterns['skips_morning'] == true) {
      goals.add(AutoGoal(
        type: 'timing',
        description: 'Schedule workouts for afternoon (2-4 PM)',
        priority: 0.8,
        reasoning: 'Your morning completion rate is low; afternoons work better for you',
      ));
    }

    // If stress is high, auto-suggest gentler activities
    if (stressLevel > 0.7) {
      goals.add(AutoGoal(
        type: 'activity',
        description: 'Replace high-intensity with yoga or walking',
        priority: 0.9,
        reasoning: 'High stress detected; gentle movement supports recovery',
      ));
    }

    // If energy is consistently low at certain times, suggest rest windows
    if (currentEnergy < 0.3) {
      goals.add(AutoGoal(
        type: 'recovery',
        description: 'Take a 20-min rest break',
        priority: 0.7,
        reasoning: 'Low energy detected; recovery will improve performance later',
      ));
    }

    return goals;
  }

  /// Karma XP System: Earn karma points for spiritual/good actions
  Future<int> awardKarmaPoints({
    required String actionType, // 'meditation', 'gratitude', 'service', 'discipline'
    required int basePoints,
    int? streakMultiplier,
  }) async {
    if (_uid == null) return 0;

    final multiplier = streakMultiplier ?? 1;
    final points = basePoints * multiplier;

    // Log karma action
    await _db.collection('users').doc(_uid).collection('karma_logs').add({
      'action_type': actionType,
      'points': points,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'multiplier': multiplier,
    });

    // Update total karma
    await _db.collection('users').doc(_uid).update({
      'total_karma': FieldValue.increment(points),
    });

    _telemetry.metricChanged('karma_points', points);

    return points;
  }

  /// Get current karma balance and level
  Future<KarmaStatus> getKarmaStatus() async {
    if (_uid == null) return KarmaStatus(currentKarma: 0, level: 1, nextLevelKarma: 100);

    final userDoc = await _db.collection('users').doc(_uid).get();
    final totalKarma = userDoc.data()?['total_karma'] as int? ?? 0;

    // Calculate level (every 100 karma = 1 level)
    final level = (totalKarma ~/ 100) + 1;
    final nextLevelKarma = level * 100;

    return KarmaStatus(
      currentKarma: totalKarma,
      level: level,
      nextLevelKarma: nextLevelKarma,
    );
  }

  /// Create accountability contract with consequences
  Future<AccountabilityContract> createContract({
    required String promise,
    required String penalty,
    bool isPublic = false,
    String? buddyId,
  }) async {
    if (_uid == null) throw Exception('Not authenticated');

    final contract = AccountabilityContract(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _uid!,
      promise: promise,
      penalty: penalty,
      isPublic: isPublic,
      buddyId: buddyId,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(_uid).collection('contracts').doc(contract.id).set({
      'promise': promise,
      'penalty': penalty,
      'is_public': isPublic,
      'buddy_id': buddyId,
      'created_at': contract.createdAt.millisecondsSinceEpoch,
      'violated': false,
    });

    return contract;
  }

  /// Check for contract violations
  Future<void> checkContractViolations() async {
    if (_uid == null) return;

    final contracts = await _db
        .collection('users')
        .doc(_uid)
        .collection('contracts')
        .where('violated', isEqualTo: false)
        .get();

    // TODO: Logic to detect violations based on missed sessions, goals, etc.
    for (final contract in contracts.docs) {
      // Example: if contract was about "workout daily" and today is missed
      // Mark as violated and trigger penalty
    }
  }
}

enum DisciplineMode { gentle, standard, push, strict }

class DisciplineResponse {
  final DisciplineMode mode;
  final String message;
  final List<DisciplineAction>? actions;

  DisciplineResponse({
    required this.mode,
    required this.message,
    this.actions,
  });
}

class DisciplineAction {
  final String type; // 'challenge', 'reflection', 'motivation'
  final String title;
  final String? reward;
  final String? penalty;

  DisciplineAction({
    required this.type,
    required this.title,
    this.reward,
    this.penalty,
  });
}

class AutoGoal {
  final String type; // 'timing', 'activity', 'recovery'
  final String description;
  final double priority; // 0.0 to 1.0
  final String reasoning;

  AutoGoal({
    required this.type,
    required this.description,
    required this.priority,
    required this.reasoning,
  });
}

class KarmaStatus {
  final int currentKarma;
  final int level;
  final int nextLevelKarma;

  KarmaStatus({
    required this.currentKarma,
    required this.level,
    required this.nextLevelKarma,
  });

  double get progress => (currentKarma % 100) / 100.0;
}

class AccountabilityContract {
  final String id;
  final String userId;
  final String promise;
  final String penalty;
  final bool isPublic;
  final String? buddyId;
  final DateTime createdAt;
  bool violated = false;

  AccountabilityContract({
    required this.id,
    required this.userId,
    required this.promise,
    required this.penalty,
    this.isPublic = false,
    this.buddyId,
    required this.createdAt,
    this.violated = false,
  });
}


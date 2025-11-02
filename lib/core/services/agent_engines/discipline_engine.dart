import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/discipline_contract.dart';

/// Discipline Engine - Accountability and gamification
class DisciplineEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final String? _uid;

  DisciplineEngine(this._db, this._auth) : _uid = _auth.currentUser?.uid;

  /// Calculate karma score (instead of coins)
  Future<KarmaScore> calculateKarmaScore() async {
    if (_uid == null) {
      return KarmaScore(current: 0, weeklyEarned: 0, totalLifetime: 0);
    }

    // Get karma logs from last week
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('karma_logs')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
        .get();

    final weeklyEarned = snapshot.docs.fold<int>(0, (sum, doc) {
      final data = doc.data();
      return sum + ((data['karma_points'] as num?)?.toInt() ?? 0);
    });

    // Get lifetime total
    final lifetimeSnapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('karma_logs')
        .get();

    final totalLifetime = lifetimeSnapshot.docs.fold<int>(0, (sum, doc) {
      final data = doc.data();
      return sum + ((data['karma_points'] as num?)?.toInt() ?? 0);
    });

    // Get current balance (stored separately)
    final userDoc = await _db.collection('users').doc(_uid).get();
    final current = (userDoc.data()?['karma_points'] as num?)?.toInt() ?? 0;

    return KarmaScore(
      current: current,
      weeklyEarned: weeklyEarned,
      totalLifetime: totalLifetime,
    );
  }

  /// Award karma for completed actions
  Future<void> awardKarma({
    required String action,
    required int points,
    String? category,
  }) async {
    if (_uid == null) return;

    final logData = {
      'userId': _uid,
      'action': action,
      'karma_points': points,
      'category': category ?? 'general',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _db.collection('users').doc(_uid).collection('karma_logs').add(logData);

    // Update current balance
    await _db.collection('users').doc(_uid).update({
      'karma_points': FieldValue.increment(points),
    });
  }

  /// Check for missed sessions and trigger accountability
  Future<AccountabilityStatus> checkAccountability() async {
    if (_uid == null) {
      return AccountabilityStatus(
        missedSessions: 0,
        streakDays: 0,
        shouldTriggerStrict: false,
      );
    }

    // Get last 7 days of workout completions
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final planned = await _getPlannedWorkouts(weekAgo);
    final completed = await _getCompletedWorkouts(weekAgo);

    final missedSessions = planned.length - completed.length;

    // Calculate streak
    final streakDays = await _calculateStreak();

    // Determine if strict mode should activate
    final shouldTriggerStrict = missedSessions >= 3 || streakDays == 0;

    return AccountabilityStatus(
      missedSessions: missedSessions,
      streakDays: streakDays,
      shouldTriggerStrict: shouldTriggerStrict,
    );
  }

  /// Create or update discipline contract
  Future<void> createContract(DisciplineContract contract) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('contracts')
        .doc(contract.id)
        .set(contract.toJson());
  }

  /// Check if contract was violated
  Future<void> checkContractViolations() async {
    if (_uid == null) return;

    final activeContracts = await _db
        .collection('users')
        .doc(_uid)
        .collection('contracts')
        .where('signedAt', isNotEqualTo: null)
        .where('violatedAt', isNull: true)
        .get();

    for (final doc in activeContracts.docs) {
      final contract = DisciplineContract.fromJson({
        'id': doc.id,
        ...doc.data(),
      });

      // Check if contract terms were violated (simplified check)
      final violated = await _checkContractTerms(contract);
      if (violated) {
        await doc.reference.update({
          'violatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getPlannedWorkouts(DateTime since) async {
    if (_uid == null) return [];
    // Would query planned workouts from calendar or goals
    return [];
  }

  Future<List<Map<String, dynamic>>> _getCompletedWorkouts(DateTime since) async {
    if (_uid == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('workout_sessions')
        .where('completedAt', isGreaterThan: Timestamp.fromDate(since))
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<int> _calculateStreak() async {
    if (_uid == null) return 0;

    // Count consecutive days with at least one workout
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    while (true) {
      final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('workout_sessions')
          .where('completedAt', isGreaterThan: Timestamp.fromDate(startOfDay))
          .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      
      // Limit check to 365 days
      if (streak > 365) break;
    }

    return streak;
  }

  Future<bool> _checkContractTerms(DisciplineContract contract) async {
    // Simplified - would check specific contract terms
    // For now, check if user has missed required sessions
    final status = await checkAccountability();
    return status.missedSessions >= 2;
  }
}

class KarmaScore {
  final int current;
  final int weeklyEarned;
  final int totalLifetime;

  KarmaScore({
    required this.current,
    required this.weeklyEarned,
    required this.totalLifetime,
  });
}

class AccountabilityStatus {
  final int missedSessions;
  final int streakDays;
  final bool shouldTriggerStrict;

  AccountabilityStatus({
    required this.missedSessions,
    required this.streakDays,
    required this.shouldTriggerStrict,
  });
}


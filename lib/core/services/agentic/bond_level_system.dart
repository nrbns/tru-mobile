import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Bond Level System: Tracks relationship depth between user and agent
class BondLevelSystem {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  BondLevelSystem(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  /// Calculate current bond level based on interaction history
  Future<BondLevel> calculateBondLevel() async {
    if (_uid == null) return BondLevel.level1;

    // Factors: interactions, consistency, depth, time
    final interactions = await _countInteractions();
    final consistency = await _calculateConsistency();
    final depth = await _calculateDepth();
    final daysSinceStart = await _calculateDaysActive();

    // Scoring system
    double score = 0.0;
    score += (interactions / 100).clamp(0.0, 0.3); // Max 30% from interactions
    score += consistency * 0.3; // 30% from consistency
    score += depth * 0.2; // 20% from depth
    score += (daysSinceStart / 30).clamp(0.0, 0.2); // 20% from time

    // Determine level
    if (score >= 0.8) return BondLevel.level4;
    if (score >= 0.6) return BondLevel.level3;
    if (score >= 0.4) return BondLevel.level2;
    return BondLevel.level1;
  }

  /// Get features unlocked at current bond level
  List<String> getUnlockedFeatures(BondLevel level) {
    switch (level) {
      case BondLevel.level1:
        return ['Chat', 'Basic tasks', 'Workout tracking'];
      case BondLevel.level2:
        return [
          'Real-time guidance',
          'AR workouts',
          'Voice interactions',
          'Camera mode',
        ];
      case BondLevel.level3:
        return [
          'Emotional sync',
          'Deep mood analysis',
          'Predictive coaching',
          'Dream analysis',
        ];
      case BondLevel.level4:
        return [
          'Life twin mode',
          'Full daily rhythm design',
          'Agent-to-agent communication',
          'Advanced AI persona',
        ];
    }
  }

  /// Award bond points for meaningful interactions
  Future<void> awardBondPoints({
    required int points,
    String? reason,
  }) async {
    if (_uid == null) return;

    await _db.collection('users').doc(_uid).collection('bond_logs').add({
      'points': points,
      'reason': reason,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _db.collection('users').doc(_uid).update({
      'bond_points': FieldValue.increment(points),
    });
  }

  Future<int> _countInteractions() async {
    final chatCount = await _db
        .collection('users')
        .doc(_uid)
        .collection('agent_inbox')
        .count()
        .get();

    final sessionCount = await _db
        .collection('users')
        .doc(_uid)
        .collection('sessions')
        .count()
        .get();

    return (chatCount.count ?? 0) + (sessionCount.count ?? 0);
  }

  Future<double> _calculateConsistency() async {
    // Check last 7 days activity
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentActivity = await _db
        .collection('users')
        .doc(_uid)
        .collection('activity_logs')
        .where('timestamp', isGreaterThan: sevenDaysAgo.millisecondsSinceEpoch)
        .count()
        .get();

    final activeDays = recentActivity.count ?? 0;
    return (activeDays / 7).clamp(0.0, 1.0);
  }

  Future<double> _calculateDepth() async {
    // Check for deep interactions (journal entries, long chats, reflections)
    final deepInteractions = await _db
        .collection('users')
        .doc(_uid)
        .collection('journal_entries')
        .count()
        .get();

    final total = (deepInteractions.count ?? 0);
    // Normalize: 10+ deep interactions = max depth
    return (total / 10).clamp(0.0, 1.0);
  }

  Future<int> _calculateDaysActive() async {
    final firstActivity = await _db
        .collection('users')
        .doc(_uid)
        .collection('activity_logs')
        .orderBy('timestamp')
        .limit(1)
        .get();

    if (firstActivity.docs.isEmpty) return 0;

    final firstTimestamp = firstActivity.docs.first.data()['timestamp'] as int?;
    if (firstTimestamp == null) return 0;

    final firstDate = DateTime.fromMillisecondsSinceEpoch(firstTimestamp);
    return DateTime.now().difference(firstDate).inDays;
  }
}

enum BondLevel {
  level1, // Basic: Chat & tasks
  level2, // Interactive: Real-time guidance
  level3, // Evolving: Emotional sync
  level4, // Merged: Life twin
}


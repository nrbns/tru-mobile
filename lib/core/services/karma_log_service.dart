import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/karma_log.dart';
import '../utils/firestore_keys.dart';

/// Service for Karma Log / Dharma Path System
/// Tracks user actions, virtues, discipline, and emotional balance
class KarmaLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('KarmaLogService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _logsRef {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.karmaLogs);
  }

  Future<void> addLog(KarmaLog log) async {
    final uid = _requireUid();
    await _logsRef.add({
      'userId': uid,
      'activity': log.activity,
      'impactScore': log.impactScore,
      'reflection': log.reflection,
      'timestamp': Timestamp.fromDate(log.timestamp),
      'category': log.category,
    });
  }

  Stream<List<Map<String, dynamic>>> streamLogs({int limit = 50}) {
    return _logsRef
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                {'id': d.id, ...(d.data() as Map<String, dynamic>? ?? {})})
            .toList());
  }

  /// Calculate karma score (sum of impact scores over time period)
  Future<int> calculateKarmaScore({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final snapshot = await _logsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    int totalScore = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      totalScore += (data['impactScore'] as int? ?? 0);
    }

    return totalScore;
  }

  /// Get karma balance (positive vs negative activities)
  Future<Map<String, dynamic>> getKarmaBalance({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final snapshot = await _logsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    int positiveCount = 0;
    int negativeCount = 0;
    int positiveScore = 0;
    int negativeScore = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final score = data['impactScore'] as int? ?? 0;

      if (score > 0) {
        positiveCount++;
        positiveScore += score;
      } else if (score < 0) {
        negativeCount++;
        negativeScore += score;
      }
    }

    return {
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'positive_score': positiveScore,
      'negative_score': negativeScore,
      'net_score': positiveScore + negativeScore,
      'balance_ratio': positiveCount > 0
          ? (positiveCount / (positiveCount + negativeCount))
          : 0.0,
    };
  }

  /// Get karma trends over time (weekly/monthly)
  Future<List<Map<String, dynamic>>> getKarmaTrends({int weeks = 12}) async {
    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int week = 0; week < weeks; week++) {
      final weekStart = now.subtract(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final snapshot = await _logsRef
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('timestamp', isLessThan: Timestamp.fromDate(weekEnd))
          .get();

      int totalScore = 0;
      int activityCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        totalScore += (data['impactScore'] as int? ?? 0);
        activityCount++;
      }

      trends.add({
        'week': week,
        'start_date': weekStart.toIso8601String(),
        'total_score': totalScore,
        'activity_count': activityCount,
        'average_score': activityCount > 0 ? (totalScore / activityCount) : 0.0,
      });
    }

    return trends.reversed.toList();
  }

  /// Get dharma path insights (virtues and growth areas)
  Future<Map<String, dynamic>> getDharmaPathInsights() async {
    final balance = await getKarmaBalance(days: 90);
    final trends = await getKarmaTrends(weeks: 12);

    // Analyze growth areas
    final snapshot =
        await _logsRef.orderBy('timestamp', descending: true).limit(100).get();

    final categoryScores = <String, int>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category'] as String? ?? 'general';
      final score = data['impactScore'] as int? ?? 0;
      categoryScores[category] = (categoryScores[category] ?? 0) + score;
    }

    // Find top virtue categories
    final sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'karma_balance': balance,
      'recent_trends': trends.take(4).toList(),
      'top_virtues': sortedCategories
          .take(3)
          .map((e) => {
                'category': e.key,
                'score': e.value,
              })
          .toList(),
      'growth_areas': sortedCategories.reversed
          .take(3)
          .map((e) => {
                'category': e.key,
                'score': e.value,
              })
          .toList(),
    };
  }
}

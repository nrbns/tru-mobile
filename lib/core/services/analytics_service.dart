import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

/// Analytics Service - Cross-domain correlation insights and trends
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('AnalyticsService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Get mood correlation with other metrics
  Future<Map<String, double>> getMoodCorrelations({int days = 30}) async {
    final uid = _requireUid();
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    // Get mood logs
    final moodSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('mood_logs')
        .where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('at', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    // Get meal logs
    final mealSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('meal_logs')
        .where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('at', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    // Get workout logs
    final workoutSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_logs')
        .where('completed_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('completed_at', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    // Get water logs
    final todayDocs = await _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .where('date',
            isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0])
        .where('date',
            isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0])
        .get();

    // Calculate correlations
    final moodScores = moodSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final at = data['at'] as Timestamp?;
      return {
        'date': at?.toDate().toIso8601String().split('T')[0] ?? '',
        'score': data['score'] as int? ?? 5,
      };
    }).toList();

    final mealCounts = <String, int>{};
    for (var doc in mealSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final at = data['at'] as Timestamp?;
      final date = at?.toDate().toIso8601String().split('T')[0] ?? '';
      mealCounts[date] = (mealCounts[date] ?? 0) + 1;
    }

    final workoutCounts = <String, int>{};
    for (var doc in workoutSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final at = data['completed_at'] as Timestamp?;
      final date = at?.toDate().toIso8601String().split('T')[0] ?? '';
      workoutCounts[date] = (workoutCounts[date] ?? 0) + 1;
    }

    final waterLevels = <String, int>{};
    for (var doc in todayDocs.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final date = doc.id;
      waterLevels[date] = data['water_ml'] as int? ?? 0;
    }

    // Calculate Pearson correlation
    double calculateCorrelation(Map<String, int> values) {
      final moodData = moodScores.map((m) => m['score'] as int).toList();
      final otherData = moodScores.map((m) {
        final date = m['date'] as String;
        return values[date]?.toDouble() ?? 0.0;
      }).toList();

      if (moodData.length < 2 || otherData.isEmpty) return 0.0;

      final moodMean = moodData.reduce((a, b) => a + b) / moodData.length;
      final otherMean = otherData.reduce((a, b) => a + b) / otherData.length;

      double numerator = 0.0;
      double moodVariance = 0.0;
      double otherVariance = 0.0;

      for (int i = 0; i < moodData.length; i++) {
        final moodDiff = moodData[i] - moodMean;
        final otherDiff = otherData[i] - otherMean;
        numerator += moodDiff * otherDiff;
        moodVariance += moodDiff * moodDiff;
        otherVariance += otherDiff * otherDiff;
      }

      final denominator = sqrt(moodVariance * otherVariance);
      if (denominator == 0) return 0.0;

      return numerator / denominator;
    }

    return {
      'workout': calculateCorrelation(workoutCounts),
      'nutrition': calculateCorrelation(mealCounts),
      'hydration': calculateCorrelation(waterLevels),
    };
  }

  /// Get trends for a specific metric
  Future<List<Map<String, dynamic>>> getMetricTrend({
    required String metric,
    int days = 30,
  }) async {
    final uid = _requireUid();
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    CollectionReference collectionRef;
    String dateField;
    String valueField;

    switch (metric) {
      case 'mood':
        collectionRef =
            _firestore.collection('users').doc(uid).collection('mood_logs');
        dateField = 'at';
        valueField = 'score';
        break;
      case 'calories':
        collectionRef =
            _firestore.collection('users').doc(uid).collection('meal_logs');
        dateField = 'at';
        valueField = 'kcal';
        break;
      case 'steps':
        collectionRef =
            _firestore.collection('users').doc(uid).collection('activity_logs');
        dateField = 'date';
        valueField = 'steps';
        break;
      default:
        return [];
    }

    final snapshot = await collectionRef
        .where(dateField, isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where(dateField, isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy(dateField)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final rawDate = data[dateField];
      final date = rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.parse(
              (rawDate ?? DateTime.now().toIso8601String()).toString());

      return {
        'date': date.toIso8601String().split('T')[0],
        'value': data[valueField] ?? 0,
      };
    }).toList();
  }

  /// Get cross-domain insights
  Future<List<Map<String, dynamic>>> getCrossDomainInsights() async {
    final correlations = await getMoodCorrelations(days: 30);
    final insights = <Map<String, dynamic>>[];

    if (correlations['workout']! > 0.5) {
      insights.add({
        'type': 'correlation',
        'domain': 'workout',
        'message':
            'Strong positive correlation: Working out improves your mood by ${(correlations['workout']! * 100).toStringAsFixed(0)}%',
        'suggestion': 'Keep up the consistent workouts!',
        'strength': correlations['workout']!,
      });
    }

    if (correlations['nutrition']! > 0.3) {
      insights.add({
        'type': 'correlation',
        'domain': 'nutrition',
        'message':
            'Moderate correlation: Regular meals correlate with better mood',
        'suggestion': 'Maintain consistent meal timing',
        'strength': correlations['nutrition']!,
      });
    }

    if (correlations['hydration']! > 0.4) {
      insights.add({
        'type': 'correlation',
        'domain': 'hydration',
        'message': 'Notable correlation: Higher hydration levels improve mood',
        'suggestion': 'Aim for 8+ glasses of water daily',
        'strength': correlations['hydration']!,
      });
    }

    return insights;
  }

  /// Get weekly comparison
  Future<Map<String, dynamic>> getWeeklyComparison() async {
    final uid = _requireUid();
    final today = DateTime.now();
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    // Get this week's data
    final thisWeekDocs = await _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .where('date',
            isGreaterThanOrEqualTo:
                thisWeekStart.toIso8601String().split('T')[0])
        .where('date',
            isLessThanOrEqualTo: today.toIso8601String().split('T')[0])
        .get();

    // Get last week's data
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    final lastWeekDocs = await _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .where('date',
            isGreaterThanOrEqualTo:
                lastWeekStart.toIso8601String().split('T')[0])
        .where('date',
            isLessThanOrEqualTo: lastWeekEnd.toIso8601String().split('T')[0])
        .get();

    double calculateAvg(List<QueryDocumentSnapshot> docs, String field) {
      if (docs.isEmpty) return 0.0;
      final values = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return (data[field] ?? 0) as num;
      }).toList();
      return values.reduce((a, b) => a + b) / values.length;
    }

    final thisWeekCalories = calculateAvg(thisWeekDocs.docs, 'kcal');
    final lastWeekCalories = calculateAvg(lastWeekDocs.docs, 'kcal');
    final thisWeekWorkouts = thisWeekDocs.docs.length;
    final lastWeekWorkouts = lastWeekDocs.docs.length;

    return {
      'calories': {
        'this_week': thisWeekCalories,
        'last_week': lastWeekCalories,
        'change': thisWeekCalories - lastWeekCalories,
        'change_percent': lastWeekCalories > 0
            ? ((thisWeekCalories - lastWeekCalories) / lastWeekCalories * 100)
            : 0.0,
      },
      'workouts': {
        'this_week': thisWeekWorkouts.toDouble(),
        'last_week': lastWeekWorkouts.toDouble(),
        'change': thisWeekWorkouts - lastWeekWorkouts,
        'change_percent': lastWeekWorkouts > 0
            ? ((thisWeekWorkouts - lastWeekWorkouts) / lastWeekWorkouts * 100)
            : 0.0,
      },
    };
  }

  // Convenience wrappers for common trends (used by providers)
  Future<List<Map<String, dynamic>>> getMoodTrends({int days = 30}) async {
    return getMetricTrend(metric: 'mood', days: days);
  }

  Future<List<Map<String, dynamic>>> getNutritionTrends({int days = 30}) async {
    return getMetricTrend(metric: 'calories', days: days);
  }

  Future<List<Map<String, dynamic>>> getWorkoutTrends({int days = 30}) async {
    return getMetricTrend(metric: 'steps', days: days);
  }

  Future<List<Map<String, dynamic>>> getSpiritualTrends({int days = 30}) async {
    // Spiritual trends may map to 'mood' or to separate spiritual collection; use mood as a fallback
    return getMetricTrend(metric: 'mood', days: days);
  }
}

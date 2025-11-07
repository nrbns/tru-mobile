import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Activity Tracking Service - Step counting, Apple Health, Google Fit integration
class ActivityTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _activityLogsRef {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('ActivityTrackingService: no authenticated user');
    }
    final uid = currentUser.uid;
    return _firestore.collection('users').doc(uid).collection('activity_logs');
  }

  /// Log activity (steps, distance, calories burned)
  Future<void> logActivity({
    required int steps,
    double? distanceKm,
    int? caloriesBurned,
    String? source, // 'manual', 'apple_health', 'google_fit', 'wearable'
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _activityLogsRef.doc(dateKey).set({
      'steps': steps,
      'distance_km': distanceKm,
      'calories_burned':
          caloriesBurned ?? (steps * 0.04).round(), // Rough estimate
      'source': source ?? 'manual',
      'updated_at': FieldValue.serverTimestamp(),
      'date': dateKey,
    }, SetOptions(merge: true));
  }

  /// Get today's activity
  Future<Map<String, dynamic>?> getTodayActivity() async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await _activityLogsRef.doc(dateKey).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'date': dateKey,
      ...data,
    };
  }

  /// Stream today's activity (real-time updates)
  Stream<Map<String, dynamic>?> streamTodayActivity() {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _activityLogsRef.doc(dateKey).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'date': dateKey,
        ...data,
      };
    });
  }

  /// Get weekly activity summary (last 7 days)
  Future<Map<String, dynamic>> getWeeklyActivitySummary() async {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 7));
    final startDateKey =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    final snapshot = await _activityLogsRef
        .where('date', isGreaterThanOrEqualTo: startDateKey)
        .get();

    int totalSteps = 0;
    double totalDistance = 0;
    int totalCalories = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      totalSteps += data['steps'] as int? ?? 0;
      totalDistance += (data['distance_km'] as num?)?.toDouble() ?? 0;
      totalCalories += data['calories_burned'] as int? ?? 0;
    }

    return {
      'total_steps': totalSteps,
      'total_distance_km': totalDistance,
      'total_calories_burned': totalCalories,
      'avg_steps_per_day': (totalSteps / 7).round(),
      'days_active': snapshot.docs.length,
    };
  }

  /// Get activity history
  Future<List<Map<String, dynamic>>> getActivityHistory({int days = 7}) async {
    final today = DateTime.now();
    final dates = List.generate(days, (i) {
      final date = today.subtract(Duration(days: i));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });

    final docs = await Future.wait(
      dates.map((dateKey) => _activityLogsRef.doc(dateKey).get()),
    );

    return docs.where((doc) => doc.exists).map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'date': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Stream activity for the last N days
  Stream<List<Map<String, dynamic>>> streamActivityHistory({int days = 7}) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: days));
    final startDateKey =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    return _activityLogsRef
        .where('date', isGreaterThanOrEqualTo: startDateKey)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'date': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get activity streak
  Future<int> getActivityStreak({int minSteps = 5000}) async {
    final today = DateTime.now();
    int streak = 0;
    DateTime currentDate = today;

    while (true) {
      final dateKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      final doc = await _activityLogsRef.doc(dateKey).get();

      if (!doc.exists) break;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final steps = data['steps'] as int? ?? 0;

      if (steps < minSteps) break;
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Sync with Apple Health (placeholder for platform channel)
  Future<void> syncAppleHealth() async {
    // TODO: Implement platform channel to access HealthKit
    // This requires native iOS code
    throw UnimplementedError(
        'Apple Health sync requires native implementation');
  }

  /// Sync with Google Fit (placeholder for platform channel)
  Future<void> syncGoogleFit() async {
    // TODO: Implement platform channel to access Google Fit API
    // This requires native Android code or Google Fit API integration
    throw UnimplementedError('Google Fit sync requires native implementation');
  }
}

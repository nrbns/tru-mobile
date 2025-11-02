import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Wearable Integration: Health Connect / Apple Health / Wearable SDKs
class WearableIntegration {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  WearableIntegration(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  /// Sync biometrics from wearables
  Future<WearableData> syncBiometrics({
    double? heartRate,
    double? hrv,
    double? bodyTemp,
    int? steps,
    double? calories,
    int? sleepMinutes,
    DateTime? timestamp,
  }) async {
    if (_uid == null) throw Exception('Not authenticated');

    final data = WearableData(
      heartRate: heartRate,
      hrv: hrv,
      bodyTemp: bodyTemp,
      steps: steps,
      calories: calories,
      sleepMinutes: sleepMinutes,
      timestamp: timestamp ?? DateTime.now(),
      source: 'wearable',
    );

    // Save to Firestore
    await _db.collection('users').doc(_uid).collection('wearable_data').add({
      'heart_rate': heartRate,
      'hrv': hrv,
      'body_temp': bodyTemp,
      'steps': steps,
      'calories': calories,
      'sleep_minutes': sleepMinutes,
      'timestamp': data.timestamp.millisecondsSinceEpoch,
      'source': 'wearable',
    });

    return data;
  }

  /// Get real-time heart rate stream
  Stream<double?>? getHeartRateStream() {
    // TODO: Implement with Health Connect / Apple Health streaming
    // Placeholder: return periodic mock data
    return Stream.periodic(
      const Duration(seconds: 1),
      (i) => 60.0 + (i % 40), // Mock HR between 60-100
    ).take(10);
  }

  /// Get HRV (Heart Rate Variability) - stress indicator
  Future<double?> getHRV() async {
    // TODO: Fetch from wearable device
    // HRV typically ranges from 20-100ms (higher = less stress)
    return 50.0; // Mock value
  }

  /// Detect sleep stages from wearable
  Future<SleepStages> getSleepStages({required DateTime sleepStart, required DateTime sleepEnd}) async {
    // TODO: Fetch from wearable device
    // Mock sleep stages
    return SleepStages(
      deep: Duration(hours: 2),
      rem: Duration(hours: 1, minutes: 30),
      light: Duration(hours: 4),
      awake: Duration(minutes: 30),
      total: sleepEnd.difference(sleepStart),
    );
  }

  /// Get activity summary (steps, active minutes, etc.)
  Future<ActivitySummary> getActivitySummary({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (_uid == null) return ActivitySummary.empty();

    // Query wearable data for the day
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final data = await _db
        .collection('users')
        .doc(_uid)
        .collection('wearable_data')
        .where('timestamp', isGreaterThan: startOfDay.millisecondsSinceEpoch)
        .where('timestamp', isLessThan: endOfDay.millisecondsSinceEpoch)
        .get();

    int totalSteps = 0;
    double totalCalories = 0.0;
    double avgHeartRate = 0.0;
    int heartRateCount = 0;

    for (final doc in data.docs) {
      final dataMap = doc.data();
      totalSteps += dataMap['steps'] as int? ?? 0;
      totalCalories += (dataMap['calories'] as num?)?.toDouble() ?? 0.0;
      if (dataMap['heart_rate'] != null) {
        avgHeartRate += (dataMap['heart_rate'] as num).toDouble();
        heartRateCount++;
      }
    }

    if (heartRateCount > 0) {
      avgHeartRate /= heartRateCount;
    }

    return ActivitySummary(
      steps: totalSteps,
      calories: totalCalories,
      avgHeartRate: heartRateCount > 0 ? avgHeartRate : null,
      activeMinutes: Duration(minutes: (totalSteps / 100).round()), // Estimate
      timestamp: targetDate,
    );
  }

  /// Check if wearable is connected
  Future<bool> isWearableConnected() async {
    // TODO: Check actual wearable connection status
    return false; // Placeholder
  }

  /// Request wearable permissions
  Future<bool> requestPermissions() async {
    // TODO: Request Health Connect / Apple Health permissions
    return false; // Placeholder
  }
}

class WearableData {
  final double? heartRate;
  final double? hrv;
  final double? bodyTemp;
  final int? steps;
  final double? calories;
  final int? sleepMinutes;
  final DateTime timestamp;
  final String source;

  WearableData({
    this.heartRate,
    this.hrv,
    this.bodyTemp,
    this.steps,
    this.calories,
    this.sleepMinutes,
    required this.timestamp,
    required this.source,
  });
}

class SleepStages {
  final Duration deep;
  final Duration rem;
  final Duration light;
  final Duration awake;
  final Duration total;

  SleepStages({
    required this.deep,
    required this.rem,
    required this.light,
    required this.awake,
    required this.total,
  });

  double get deepPercentage => (deep.inMinutes / total.inMinutes) * 100;
  double get remPercentage => (rem.inMinutes / total.inMinutes) * 100;
  double get qualityScore => (deepPercentage * 0.4 + remPercentage * 0.4 + (1 - awake.inMinutes / total.inMinutes) * 20);
}

class ActivitySummary {
  final int steps;
  final double calories;
  final double? avgHeartRate;
  final Duration activeMinutes;
  final DateTime timestamp;

  ActivitySummary({
    required this.steps,
    required this.calories,
    this.avgHeartRate,
    required this.activeMinutes,
    required this.timestamp,
  });

  factory ActivitySummary.empty() {
    return ActivitySummary(
      steps: 0,
      calories: 0.0,
      activeMinutes: Duration.zero,
      timestamp: DateTime.now(),
    );
  }
}


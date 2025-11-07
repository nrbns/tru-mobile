import 'package:json_annotation/json_annotation.dart';
import 'device_data.dart';

part 'health_metrics.g.dart';

@JsonSerializable()
class HealthMetrics {
  HealthMetrics({
    required this.timestamp,
    this.heartRate,
    this.steps,
    this.calories,
    this.distance,
    this.activeMinutes,
    this.sleepHours,
    this.bloodOxygen,
    this.bloodPressure,
    this.deviceId,
    this.additionalMetrics,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) =>
      _$HealthMetricsFromJson(json);
  final DateTime timestamp;
  final int? heartRate;
  final int? steps;
  final int? calories;
  final double? distance;
  final int? activeMinutes;
  final double? sleepHours;
  final int? bloodOxygen;
  final BloodPressure? bloodPressure;
  final String? deviceId;
  final Map<String, dynamic>? additionalMetrics;
  Map<String, dynamic> toJson() => _$HealthMetricsToJson(this);

  /// Get heart rate zone
  String getHeartRateZone() {
    if (heartRate == null) return 'Unknown';

    if (heartRate! < 60) return 'Resting';
    if (heartRate! < 100) return 'Fat Burn';
    if (heartRate! < 120) return 'Cardio';
    if (heartRate! < 140) return 'Peak';
    return 'Maximum';
  }

  /// Get activity level based on steps
  String getActivityLevel() {
    if (steps == null) return 'Unknown';

    if (steps! < 5000) return 'Sedentary';
    if (steps! < 7500) return 'Lightly Active';
    if (steps! < 10000) return 'Moderately Active';
    if (steps! < 12500) return 'Very Active';
    return 'Extremely Active';
  }

  /// Get sleep quality
  String getSleepQuality() {
    if (sleepHours == null) return 'Unknown';

    if (sleepHours! < 6) return 'Poor';
    if (sleepHours! < 7) return 'Fair';
    if (sleepHours! < 8) return 'Good';
    if (sleepHours! < 9) return 'Very Good';
    return 'Excellent';
  }

  /// Calculate calories burned per hour
  double getCaloriesPerHour() {
    if (calories == null || activeMinutes == null || activeMinutes == 0) {
      return 0.0;
    }
    return (calories! / activeMinutes!) * 60;
  }

  /// Get distance in preferred unit
  String getFormattedDistance() {
    if (distance == null) return '0.0 km';
    return '${distance!.toStringAsFixed(1)} km';
  }

  /// Get formatted active time
  String getFormattedActiveTime() {
    if (activeMinutes == null) return '0 min';

    final hours = activeMinutes! ~/ 60;
    final minutes = activeMinutes! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

@JsonSerializable()
class DailyHealthSummary {
  DailyHealthSummary({
    required this.date,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalDistance,
    required this.totalActiveMinutes,
    required this.totalSleepHours,
    required this.averageHeartRate,
    this.maxHeartRate,
    this.minHeartRate,
    required this.hourlyData,
    this.insights,
  });

  factory DailyHealthSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthSummaryFromJson(json);
  final DateTime date;
  final int totalSteps;
  final int totalCalories;
  final double totalDistance;
  final int totalActiveMinutes;
  final double totalSleepHours;
  final int averageHeartRate;
  final int? maxHeartRate;
  final int? minHeartRate;
  final List<HealthMetrics> hourlyData;
  final Map<String, dynamic>? insights;
  Map<String, dynamic> toJson() => _$DailyHealthSummaryToJson(this);

  /// Get daily activity score (0-100)
  int getActivityScore() {
    int score = 0;

    // Steps score (40 points max)
    if (totalSteps >= 10000) {
      score += 40;
    } else if (totalSteps >= 7500) {
      score += 30;
    } else if (totalSteps >= 5000) {
      score += 20;
    } else if (totalSteps >= 2500) {
      score += 10;
    }

    // Active minutes score (30 points max)
    if (totalActiveMinutes >= 60) {
      score += 30;
    } else if (totalActiveMinutes >= 45) {
      score += 25;
    } else if (totalActiveMinutes >= 30) {
      score += 20;
    } else if (totalActiveMinutes >= 15) {
      score += 10;
    }

    // Calories score (20 points max)
    if (totalCalories >= 500) {
      score += 20;
    } else if (totalCalories >= 400) {
      score += 15;
    } else if (totalCalories >= 300) {
      score += 10;
    } else if (totalCalories >= 200) {
      score += 5;
    }

    // Sleep score (10 points max)
    if (totalSleepHours >= 8) {
      score += 10;
    } else if (totalSleepHours >= 7) {
      score += 8;
    } else if (totalSleepHours >= 6) {
      score += 5;
    } else if (totalSleepHours >= 5) {
      score += 2;
    }

    return score;
  }

  /// Get daily insights
  List<String> getDailyInsights() {
    final insights = <String>[];

    if (totalSteps >= 10000) {
      insights.add('Great job! You reached your daily step goal!');
    } else if (totalSteps >= 7500) {
      insights.add('You\'re close to your step goal. Keep it up!');
    } else {
      insights.add('Try to increase your daily steps for better health.');
    }

    if (totalActiveMinutes >= 30) {
      insights.add('Excellent! You got plenty of active minutes today.');
    } else if (totalActiveMinutes >= 15) {
      insights.add('Good work on staying active today.');
    } else {
      insights.add('Try to add more active minutes to your day.');
    }

    if (totalSleepHours >= 7 && totalSleepHours <= 9) {
      insights.add('Perfect sleep duration! You\'re well-rested.');
    } else if (totalSleepHours < 7) {
      insights.add('Consider getting more sleep for better recovery.');
    } else if (totalSleepHours > 9) {
      insights.add('You got plenty of sleep today. How do you feel?');
    }

    return insights;
  }
}

@JsonSerializable()
class WeeklyHealthTrend {
  WeeklyHealthTrend({
    required this.startDate,
    required this.endDate,
    required this.dailySummaries,
    required this.averageMetrics,
    required this.trends,
  });

  factory WeeklyHealthTrend.fromJson(Map<String, dynamic> json) =>
      _$WeeklyHealthTrendFromJson(json);
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyHealthSummary> dailySummaries;
  final Map<String, double> averageMetrics;
  final Map<String, String> trends;
  Map<String, dynamic> toJson() => _$WeeklyHealthTrendToJson(this);

  /// Calculate weekly trends
  static Map<String, String> calculateTrends(
      List<DailyHealthSummary> summaries) {
    if (summaries.length < 2) return {};

    final trends = <String, String>{};

    // Calculate steps trend
    final firstWeekSteps =
        summaries.take(3).map((s) => s.totalSteps).reduce((a, b) => a + b) / 3;
    final lastWeekSteps =
        summaries.skip(4).map((s) => s.totalSteps).reduce((a, b) => a + b) / 3;
    trends['steps'] =
        lastWeekSteps > firstWeekSteps ? 'increasing' : 'decreasing';

    // Calculate calories trend
    final firstWeekCalories =
        summaries.take(3).map((s) => s.totalCalories).reduce((a, b) => a + b) /
            3;
    final lastWeekCalories =
        summaries.skip(4).map((s) => s.totalCalories).reduce((a, b) => a + b) /
            3;
    trends['calories'] =
        lastWeekCalories > firstWeekCalories ? 'increasing' : 'decreasing';

    // Calculate sleep trend
    final firstWeekSleep = summaries
            .take(3)
            .map((s) => s.totalSleepHours)
            .reduce((a, b) => a + b) /
        3;
    final lastWeekSleep = summaries
            .skip(4)
            .map((s) => s.totalSleepHours)
            .reduce((a, b) => a + b) /
        3;
    trends['sleep'] =
        lastWeekSleep > firstWeekSleep ? 'improving' : 'declining';

    return trends;
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthMetrics _$HealthMetricsFromJson(Map<String, dynamic> json) =>
    HealthMetrics(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: (json['heartRate'] as num?)?.toInt(),
      steps: (json['steps'] as num?)?.toInt(),
      calories: (json['calories'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      activeMinutes: (json['activeMinutes'] as num?)?.toInt(),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      bloodOxygen: (json['bloodOxygen'] as num?)?.toInt(),
      bloodPressure: json['bloodPressure'] == null
          ? null
          : BloodPressure.fromJson(
              json['bloodPressure'] as Map<String, dynamic>),
      deviceId: json['deviceId'] as String?,
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$HealthMetricsToJson(HealthMetrics instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'heartRate': instance.heartRate,
      'steps': instance.steps,
      'calories': instance.calories,
      'distance': instance.distance,
      'activeMinutes': instance.activeMinutes,
      'sleepHours': instance.sleepHours,
      'bloodOxygen': instance.bloodOxygen,
      'bloodPressure': instance.bloodPressure,
      'deviceId': instance.deviceId,
      'additionalMetrics': instance.additionalMetrics,
    };

DailyHealthSummary _$DailyHealthSummaryFromJson(Map<String, dynamic> json) =>
    DailyHealthSummary(
      date: DateTime.parse(json['date'] as String),
      totalSteps: (json['totalSteps'] as num).toInt(),
      totalCalories: (json['totalCalories'] as num).toInt(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalActiveMinutes: (json['totalActiveMinutes'] as num).toInt(),
      totalSleepHours: (json['totalSleepHours'] as num).toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num).toInt(),
      maxHeartRate: (json['maxHeartRate'] as num?)?.toInt(),
      minHeartRate: (json['minHeartRate'] as num?)?.toInt(),
      hourlyData: (json['hourlyData'] as List<dynamic>)
          .map((e) => HealthMetrics.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights: json['insights'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DailyHealthSummaryToJson(DailyHealthSummary instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalSteps': instance.totalSteps,
      'totalCalories': instance.totalCalories,
      'totalDistance': instance.totalDistance,
      'totalActiveMinutes': instance.totalActiveMinutes,
      'totalSleepHours': instance.totalSleepHours,
      'averageHeartRate': instance.averageHeartRate,
      'maxHeartRate': instance.maxHeartRate,
      'minHeartRate': instance.minHeartRate,
      'hourlyData': instance.hourlyData,
      'insights': instance.insights,
    };

WeeklyHealthTrend _$WeeklyHealthTrendFromJson(Map<String, dynamic> json) =>
    WeeklyHealthTrend(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      dailySummaries: (json['dailySummaries'] as List<dynamic>)
          .map((e) => DailyHealthSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageMetrics: (json['averageMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      trends: Map<String, String>.from(json['trends'] as Map),
    );

Map<String, dynamic> _$WeeklyHealthTrendToJson(WeeklyHealthTrend instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'dailySummaries': instance.dailySummaries,
      'averageMetrics': instance.averageMetrics,
      'trends': instance.trends,
    };

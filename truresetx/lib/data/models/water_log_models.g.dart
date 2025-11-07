// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterLog _$WaterLogFromJson(Map<String, dynamic> json) => WaterLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WaterLogToJson(WaterLog instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
    };

WaterGoal _$WaterGoalFromJson(Map<String, dynamic> json) => WaterGoal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dailyGoal: (json['dailyGoal'] as num).toDouble(),
      unit: json['unit'] as String,
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => WaterReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WaterGoalToJson(WaterGoal instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dailyGoal': instance.dailyGoal,
      'unit': instance.unit,
      'reminders': instance.reminders,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

WaterReminder _$WaterReminderFromJson(Map<String, dynamic> json) =>
    WaterReminder(
      id: json['id'] as String,
      time: json['time'] as String,
      message: json['message'] as String,
      isEnabled: json['isEnabled'] as bool,
    );

Map<String, dynamic> _$WaterReminderToJson(WaterReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'message': instance.message,
      'isEnabled': instance.isEnabled,
    };

WaterStats _$WaterStatsFromJson(Map<String, dynamic> json) => WaterStats(
      date: DateTime.parse(json['date'] as String),
      totalIntake: (json['totalIntake'] as num).toDouble(),
      goal: (json['goal'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      logCount: (json['logCount'] as num).toInt(),
      averageAmount: (json['averageAmount'] as num?)?.toDouble(),
      peakHour: (json['peakHour'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WaterStatsToJson(WaterStats instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalIntake': instance.totalIntake,
      'goal': instance.goal,
      'percentage': instance.percentage,
      'logCount': instance.logCount,
      'averageAmount': instance.averageAmount,
      'peakHour': instance.peakHour,
    };

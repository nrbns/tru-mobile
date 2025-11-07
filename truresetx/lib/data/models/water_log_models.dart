import 'package:json_annotation/json_annotation.dart';

part 'water_log_models.g.dart';

@JsonSerializable()
class WaterLog {
  WaterLog({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
    this.notes,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) =>
      _$WaterLogFromJson(json);

  final String id;
  final String userId;
  final double amount; // in ml
  final DateTime timestamp;
  final String? notes;

  Map<String, dynamic> toJson() => _$WaterLogToJson(this);
}

@JsonSerializable()
class WaterGoal {
  WaterGoal({
    required this.id,
    required this.userId,
    required this.dailyGoal,
    required this.unit,
    this.reminders = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory WaterGoal.fromJson(Map<String, dynamic> json) =>
      _$WaterGoalFromJson(json);

  final String id;
  final String userId;
  final double dailyGoal; // in ml
  final String unit; // ml, oz, cups
  final List<WaterReminder> reminders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$WaterGoalToJson(this);
}

@JsonSerializable()
class WaterReminder {
  WaterReminder({
    required this.id,
    required this.time,
    required this.message,
    required this.isEnabled,
  });

  factory WaterReminder.fromJson(Map<String, dynamic> json) =>
      _$WaterReminderFromJson(json);

  final String id;
  final String time; // HH:mm format
  final String message;
  final bool isEnabled;

  Map<String, dynamic> toJson() => _$WaterReminderToJson(this);
}

@JsonSerializable()
class WaterStats {
  WaterStats({
    required this.date,
    required this.totalIntake,
    required this.goal,
    required this.percentage,
    required this.logCount,
    this.averageAmount,
    this.peakHour,
  });

  factory WaterStats.fromJson(Map<String, dynamic> json) =>
      _$WaterStatsFromJson(json);

  final DateTime date;
  final double totalIntake;
  final double goal;
  final double percentage;
  final int logCount;
  final double? averageAmount;
  final int? peakHour; // 0-23

  Map<String, dynamic> toJson() => _$WaterStatsToJson(this);
}

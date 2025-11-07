import 'package:json_annotation/json_annotation.dart';

part 'device_data.g.dart';

@JsonSerializable()
class DeviceData {
  DeviceData({
    required this.deviceId,
    required this.deviceType,
    required this.timestamp,
    this.heartRate,
    this.steps,
    this.calories,
    this.distance,
    this.activeMinutes,
    this.sleepHours,
    this.bloodOxygen,
    this.bloodPressure,
    this.workouts,
    this.sleepData,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) =>
      _$DeviceDataFromJson(json);

  final String deviceId;
  final String deviceType;
  final DateTime timestamp;
  final int? heartRate;
  final int? steps;
  final int? calories;
  final double? distance;
  final int? activeMinutes;
  final double? sleepHours;
  final int? bloodOxygen;
  final BloodPressure? bloodPressure;
  final List<WorkoutData>? workouts;
  final SleepData? sleepData;
  Map<String, dynamic> toJson() => _$DeviceDataToJson(this);
}

@JsonSerializable()
class BloodPressure {
  BloodPressure({
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
  });

  factory BloodPressure.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureFromJson(json);

  final int systolic;
  final int diastolic;
  final DateTime timestamp;
  Map<String, dynamic> toJson() => _$BloodPressureToJson(this);
}

@JsonSerializable()
class WorkoutData {
  WorkoutData({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.calories,
    this.distance,
    this.averageHeartRate,
    this.maxHeartRate,
    this.additionalData,
  });

  factory WorkoutData.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDataFromJson(json);

  final String id;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final int? calories;
  final double? distance;
  final int? averageHeartRate;
  final int? maxHeartRate;
  final Map<String, dynamic>? additionalData;
  Map<String, dynamic> toJson() => _$WorkoutDataToJson(this);
}

@JsonSerializable()
class SleepData {
  SleepData({
    required this.sleepStart,
    required this.sleepEnd,
    required this.totalSleepMinutes,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.awakeMinutes,
    this.sleepScore,
    this.sleepStages,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) =>
      _$SleepDataFromJson(json);

  final DateTime sleepStart;
  final DateTime sleepEnd;
  final int totalSleepMinutes;
  final int deepSleepMinutes;
  final int lightSleepMinutes;
  final int remSleepMinutes;
  final int awakeMinutes;
  final int? sleepScore;
  final List<SleepStage>? sleepStages;
  Map<String, dynamic> toJson() => _$SleepDataToJson(this);
}

@JsonSerializable()
class SleepStage {
  SleepStage({
    required this.stage,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  factory SleepStage.fromJson(Map<String, dynamic> json) =>
      _$SleepStageFromJson(json);

  final String stage; // deep, light, rem, awake
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  Map<String, dynamic> toJson() => _$SleepStageToJson(this);
}

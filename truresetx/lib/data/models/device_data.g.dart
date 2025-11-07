// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceData _$DeviceDataFromJson(Map<String, dynamic> json) => DeviceData(
      deviceId: json['deviceId'] as String,
      deviceType: json['deviceType'] as String,
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
      workouts: (json['workouts'] as List<dynamic>?)
          ?.map((e) => WorkoutData.fromJson(e as Map<String, dynamic>))
          .toList(),
      sleepData: json['sleepData'] == null
          ? null
          : SleepData.fromJson(json['sleepData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeviceDataToJson(DeviceData instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'deviceType': instance.deviceType,
      'timestamp': instance.timestamp.toIso8601String(),
      'heartRate': instance.heartRate,
      'steps': instance.steps,
      'calories': instance.calories,
      'distance': instance.distance,
      'activeMinutes': instance.activeMinutes,
      'sleepHours': instance.sleepHours,
      'bloodOxygen': instance.bloodOxygen,
      'bloodPressure': instance.bloodPressure,
      'workouts': instance.workouts,
      'sleepData': instance.sleepData,
    };

BloodPressure _$BloodPressureFromJson(Map<String, dynamic> json) =>
    BloodPressure(
      systolic: (json['systolic'] as num).toInt(),
      diastolic: (json['diastolic'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$BloodPressureToJson(BloodPressure instance) =>
    <String, dynamic>{
      'systolic': instance.systolic,
      'diastolic': instance.diastolic,
      'timestamp': instance.timestamp.toIso8601String(),
    };

WorkoutData _$WorkoutDataFromJson(Map<String, dynamic> json) => WorkoutData(
      id: json['id'] as String,
      type: json['type'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: (json['duration'] as num).toInt(),
      calories: (json['calories'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num?)?.toInt(),
      maxHeartRate: (json['maxHeartRate'] as num?)?.toInt(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WorkoutDataToJson(WorkoutData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'duration': instance.duration,
      'calories': instance.calories,
      'distance': instance.distance,
      'averageHeartRate': instance.averageHeartRate,
      'maxHeartRate': instance.maxHeartRate,
      'additionalData': instance.additionalData,
    };

SleepData _$SleepDataFromJson(Map<String, dynamic> json) => SleepData(
      sleepStart: DateTime.parse(json['sleepStart'] as String),
      sleepEnd: DateTime.parse(json['sleepEnd'] as String),
      totalSleepMinutes: (json['totalSleepMinutes'] as num).toInt(),
      deepSleepMinutes: (json['deepSleepMinutes'] as num).toInt(),
      lightSleepMinutes: (json['lightSleepMinutes'] as num).toInt(),
      remSleepMinutes: (json['remSleepMinutes'] as num).toInt(),
      awakeMinutes: (json['awakeMinutes'] as num).toInt(),
      sleepScore: (json['sleepScore'] as num?)?.toInt(),
      sleepStages: (json['sleepStages'] as List<dynamic>?)
          ?.map((e) => SleepStage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SleepDataToJson(SleepData instance) => <String, dynamic>{
      'sleepStart': instance.sleepStart.toIso8601String(),
      'sleepEnd': instance.sleepEnd.toIso8601String(),
      'totalSleepMinutes': instance.totalSleepMinutes,
      'deepSleepMinutes': instance.deepSleepMinutes,
      'lightSleepMinutes': instance.lightSleepMinutes,
      'remSleepMinutes': instance.remSleepMinutes,
      'awakeMinutes': instance.awakeMinutes,
      'sleepScore': instance.sleepScore,
      'sleepStages': instance.sleepStages,
    };

SleepStage _$SleepStageFromJson(Map<String, dynamic> json) => SleepStage(
      stage: json['stage'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$SleepStageToJson(SleepStage instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
    };

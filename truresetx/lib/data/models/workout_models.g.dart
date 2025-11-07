// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String?,
      planJson: json['planJson'] as Map<String, dynamic>,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'planJson': instance.planJson,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) => WorkoutPlan(
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String?,
      focus: json['focus'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'exercises': instance.exercises,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
      'focus': instance.focus,
      'notes': instance.notes,
    };

WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    WorkoutExercise(
      exerciseId: (json['exerciseId'] as num).toInt(),
      name: json['name'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      restTime: (json['restTime'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      arTargets: json['arTargets'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WorkoutExerciseToJson(WorkoutExercise instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'name': instance.name,
      'primaryMuscle': instance.primaryMuscle,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'restTime': instance.restTime,
      'notes': instance.notes,
      'arTargets': instance.arTargets,
    };

SetLog _$SetLogFromJson(Map<String, dynamic> json) => SetLog(
      id: (json['id'] as num).toInt(),
      workoutId: (json['workoutId'] as num).toInt(),
      exerciseId: (json['exerciseId'] as num).toInt(),
      setNo: (json['setNo'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      repMetrics: (json['repMetrics'] as List<dynamic>)
          .map((e) => RepMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      arScores: json['arScores'] as Map<String, dynamic>,
      painFlag: json['painFlag'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SetLogToJson(SetLog instance) => <String, dynamic>{
      'id': instance.id,
      'workoutId': instance.workoutId,
      'exerciseId': instance.exerciseId,
      'setNo': instance.setNo,
      'reps': instance.reps,
      'repMetrics': instance.repMetrics,
      'arScores': instance.arScores,
      'painFlag': instance.painFlag,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

RepMetric _$RepMetricFromJson(Map<String, dynamic> json) => RepMetric(
      repNumber: (json['repNumber'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metrics: json['metrics'] as Map<String, dynamic>,
      quality: (json['quality'] as num?)?.toDouble(),
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RepMetricToJson(RepMetric instance) => <String, dynamic>{
      'repNumber': instance.repNumber,
      'timestamp': instance.timestamp.toIso8601String(),
      'metrics': instance.metrics,
      'quality': instance.quality,
      'errors': instance.errors,
    };

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    WorkoutSession(
      workout: Workout.fromJson(json['workout'] as Map<String, dynamic>),
      setLogs: (json['setLogs'] as List<dynamic>)
          .map((e) => SetLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      totalDuration: (json['totalDuration'] as num?)?.toInt(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) =>
    <String, dynamic>{
      'workout': instance.workout,
      'setLogs': instance.setLogs,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'totalDuration': instance.totalDuration,
      'caloriesBurned': instance.caloriesBurned,
      'notes': instance.notes,
    };

ARTargets _$ARTargetsFromJson(Map<String, dynamic> json) => ARTargets(
      exerciseId: (json['exerciseId'] as num).toInt(),
      targets: json['targets'] as Map<String, dynamic>,
      tempo: json['tempo'] as Map<String, dynamic>?,
      cues: (json['cues'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ARTargetsToJson(ARTargets instance) => <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'targets': instance.targets,
      'tempo': instance.tempo,
      'cues': instance.cues,
    };

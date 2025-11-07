// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      equipment:
          (json['equipment'] as List<dynamic>).map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      cues: (json['cues'] as List<dynamic>).map((e) => e as String).toList(),
      arErrRules: json['arErrRules'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'primaryMuscle': instance.primaryMuscle,
      'secondaryMuscles': instance.secondaryMuscles,
      'equipment': instance.equipment,
      'videoUrl': instance.videoUrl,
      'cues': instance.cues,
      'arErrRules': instance.arErrRules,
    };

ExerciseList _$ExerciseListFromJson(Map<String, dynamic> json) => ExerciseList(
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      filteredMuscle: json['filteredMuscle'] as String?,
    );

Map<String, dynamic> _$ExerciseListToJson(ExerciseList instance) =>
    <String, dynamic>{
      'exercises': instance.exercises,
      'totalCount': instance.totalCount,
      'filteredMuscle': instance.filteredMuscle,
    };

ARErrorRule _$ARErrorRuleFromJson(Map<String, dynamic> json) => ARErrorRule(
      condition: json['condition'] as String,
      countIfRepsOver: (json['countIfRepsOver'] as num).toDouble(),
      cue: json['cue'] as String,
      threshold: (json['threshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ARErrorRuleToJson(ARErrorRule instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'countIfRepsOver': instance.countIfRepsOver,
      'cue': instance.cue,
      'threshold': instance.threshold,
    };

ExerciseCategory _$ExerciseCategoryFromJson(Map<String, dynamic> json) =>
    ExerciseCategory(
      name: json['name'] as String,
      muscles:
          (json['muscles'] as List<dynamic>).map((e) => e as String).toList(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$ExerciseCategoryToJson(ExerciseCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'muscles': instance.muscles,
      'exercises': instance.exercises,
      'icon': instance.icon,
      'color': instance.color,
    };

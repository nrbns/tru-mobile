// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodLog _$MoodLogFromJson(Map<String, dynamic> json) => MoodLog(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      who5Raw: (json['who5Raw'] as num).toInt(),
      who5Pct: (json['who5Pct'] as num).toInt(),
      energy: (json['energy'] as num).toInt(),
      stress: (json['stress'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MoodLogToJson(MoodLog instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'who5Raw': instance.who5Raw,
      'who5Pct': instance.who5Pct,
      'energy': instance.energy,
      'stress': instance.stress,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

Who5Item _$Who5ItemFromJson(Map<String, dynamic> json) => Who5Item(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      scale: (json['scale'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$Who5ItemToJson(Who5Item instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'scale': instance.scale,
      'description': instance.description,
    };

Who5Assessment _$Who5AssessmentFromJson(Map<String, dynamic> json) =>
    Who5Assessment(
      items: (json['items'] as List<dynamic>)
          .map((e) => Who5Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      percentage: (json['percentage'] as num).toInt(),
      category: $enumDecode(_$MoodCategoryEnumMap, json['category']),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$Who5AssessmentToJson(Who5Assessment instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalScore': instance.totalScore,
      'percentage': instance.percentage,
      'category': _$MoodCategoryEnumMap[instance.category]!,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$MoodCategoryEnumMap = {
  MoodCategory.excellent: 'excellent',
  MoodCategory.good: 'good',
  MoodCategory.fair: 'fair',
  MoodCategory.poor: 'poor',
  MoodCategory.veryPoor: 'veryPoor',
};

MoodSummary _$MoodSummaryFromJson(Map<String, dynamic> json) => MoodSummary(
      week: json['week'] as String,
      averageMood: (json['averageMood'] as num).toDouble(),
      moodTrend: json['moodTrend'] as String,
      energyTrend: json['energyTrend'] as String,
      stressTrend: json['stressTrend'] as String,
      dailyLogs: (json['dailyLogs'] as List<dynamic>)
          .map((e) => MoodLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights:
          (json['insights'] as List<dynamic>).map((e) => e as String).toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MoodSummaryToJson(MoodSummary instance) =>
    <String, dynamic>{
      'week': instance.week,
      'averageMood': instance.averageMood,
      'moodTrend': instance.moodTrend,
      'energyTrend': instance.energyTrend,
      'stressTrend': instance.stressTrend,
      'dailyLogs': instance.dailyLogs,
      'insights': instance.insights,
      'recommendations': instance.recommendations,
    };

MoodInsight _$MoodInsightFromJson(Map<String, dynamic> json) => MoodInsight(
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MoodInsightToJson(MoodInsight instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'severity': instance.severity,
      'actionItems': instance.actionItems,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wisdom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WisdomModelImpl _$$WisdomModelImplFromJson(Map<String, dynamic> json) =>
    _$WisdomModelImpl(
      id: json['id'] as String,
      source: json['source'] as String,
      category: json['category'] as String,
      language: json['language'] as String?,
      verse: json['verse'] as String?,
      translation: json['translation'] as String,
      meaning: json['meaning'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      moodFit:
          (json['moodFit'] as List<dynamic>?)?.map((e) => e as String).toList(),
      audioUrl: json['audioUrl'] as String?,
      level: json['level'] as String? ?? 'universal',
      author: json['author'] as String?,
      era: json['era'] as String?,
      tradition: json['tradition'] as String?,
    );

Map<String, dynamic> _$$WisdomModelImplToJson(_$WisdomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'category': instance.category,
      'language': instance.language,
      'verse': instance.verse,
      'translation': instance.translation,
      'meaning': instance.meaning,
      'tags': instance.tags,
      'moodFit': instance.moodFit,
      'audioUrl': instance.audioUrl,
      'level': instance.level,
      'author': instance.author,
      'era': instance.era,
      'tradition': instance.tradition,
    };

_$WisdomReflectionModelImpl _$$WisdomReflectionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WisdomReflectionModelImpl(
      id: json['id'] as String,
      wisdomId: json['wisdomId'] as String,
      userId: json['userId'] as String,
      reflectionText: json['reflectionText'] as String?,
      moodBefore: (json['moodBefore'] as num?)?.toInt(),
      moodAfter: (json['moodAfter'] as num?)?.toInt(),
      insights: (json['insights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      appliedToday: json['appliedToday'] as bool? ?? false,
      reflectedAt: json['reflectedAt'] == null
          ? null
          : DateTime.parse(json['reflectedAt'] as String),
    );

Map<String, dynamic> _$$WisdomReflectionModelImplToJson(
        _$WisdomReflectionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wisdomId': instance.wisdomId,
      'userId': instance.userId,
      'reflectionText': instance.reflectionText,
      'moodBefore': instance.moodBefore,
      'moodAfter': instance.moodAfter,
      'insights': instance.insights,
      'appliedToday': instance.appliedToday,
      'reflectedAt': instance.reflectedAt?.toIso8601String(),
    };

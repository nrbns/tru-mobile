// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spiritual_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScriptureSource _$ScriptureSourceFromJson(Map<String, dynamic> json) =>
    ScriptureSource(
      id: (json['id'] as num).toInt(),
      tradition: json['tradition'] as String,
      work: json['work'] as String,
      lang: json['lang'] as String,
      license: json['license'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ScriptureSourceToJson(ScriptureSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tradition': instance.tradition,
      'work': instance.work,
      'lang': instance.lang,
      'license': instance.license,
      'notes': instance.notes,
    };

ScriptureVerse _$ScriptureVerseFromJson(Map<String, dynamic> json) =>
    ScriptureVerse(
      id: (json['id'] as num).toInt(),
      sourceId: (json['sourceId'] as num).toInt(),
      chapter: (json['chapter'] as num).toInt(),
      verse: (json['verse'] as num).toInt(),
      textOriginal: json['textOriginal'] as String,
      textTranslation: json['textTranslation'] as String,
      audioUrl: json['audioUrl'] as String?,
    );

Map<String, dynamic> _$ScriptureVerseToJson(ScriptureVerse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceId': instance.sourceId,
      'chapter': instance.chapter,
      'verse': instance.verse,
      'textOriginal': instance.textOriginal,
      'textTranslation': instance.textTranslation,
      'audioUrl': instance.audioUrl,
    };

GitaVerse _$GitaVerseFromJson(Map<String, dynamic> json) => GitaVerse(
      chapter: (json['chapter'] as num).toInt(),
      verse: (json['verse'] as num).toInt(),
      sanskrit: json['sanskrit'] as String,
      translation: json['translation'] as String,
      transliteration: json['transliteration'] as String?,
      audioUrl: json['audioUrl'] as String?,
      commentary: json['commentary'] as String?,
    );

Map<String, dynamic> _$GitaVerseToJson(GitaVerse instance) => <String, dynamic>{
      'chapter': instance.chapter,
      'verse': instance.verse,
      'sanskrit': instance.sanskrit,
      'translation': instance.translation,
      'transliteration': instance.transliteration,
      'audioUrl': instance.audioUrl,
      'commentary': instance.commentary,
    };

WisdomItem _$WisdomItemFromJson(Map<String, dynamic> json) => WisdomItem(
      id: (json['id'] as num).toInt(),
      category: json['category'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      durationMin: (json['durationMin'] as num).toInt(),
      ambiance: json['ambiance'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WisdomItemToJson(WisdomItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'title': instance.title,
      'body': instance.body,
      'durationMin': instance.durationMin,
      'ambiance': instance.ambiance,
    };

DailyWisdom _$DailyWisdomFromJson(Map<String, dynamic> json) => DailyWisdom(
      date: DateTime.parse(json['date'] as String),
      wisdomItem:
          WisdomItem.fromJson(json['wisdomItem'] as Map<String, dynamic>),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DailyWisdomToJson(DailyWisdom instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'wisdomItem': instance.wisdomItem,
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
    };

SpiritualProgress _$SpiritualProgressFromJson(Map<String, dynamic> json) =>
    SpiritualProgress(
      period: json['period'] as String,
      totalWisdomItems: (json['totalWisdomItems'] as num).toInt(),
      completedItems: (json['completedItems'] as num).toInt(),
      totalVerses: (json['totalVerses'] as num).toInt(),
      readVerses: (json['readVerses'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      insights:
          (json['insights'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SpiritualProgressToJson(SpiritualProgress instance) =>
    <String, dynamic>{
      'period': instance.period,
      'totalWisdomItems': instance.totalWisdomItems,
      'completedItems': instance.completedItems,
      'totalVerses': instance.totalVerses,
      'readVerses': instance.readVerses,
      'streak': instance.streak,
      'insights': instance.insights,
    };

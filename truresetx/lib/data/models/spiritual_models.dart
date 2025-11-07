import 'package:json_annotation/json_annotation.dart';

part 'spiritual_models.g.dart';

@JsonSerializable()
class ScriptureSource {
  ScriptureSource({
    required this.id,
    required this.tradition,
    required this.work,
    required this.lang,
    this.license,
    this.notes,
  });

  factory ScriptureSource.fromJson(Map<String, dynamic> json) => _$ScriptureSourceFromJson(json);

  final int id;
  final String tradition;
  final String work;
  final String lang;
  final String? license;
  final String? notes;

  Map<String, dynamic> toJson() => _$ScriptureSourceToJson(this);

  /// Get display name
  String get displayName => '$work ($tradition)';

  /// Get language display name
  String get languageDisplayName {
    switch (lang.toLowerCase()) {
      case 'en':
        return 'English';
      case 'sa':
        return 'Sanskrit';
      case 'hi':
        return 'Hindi';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'kn':
        return 'Kannada';
      case 'ml':
        return 'Malayalam';
      case 'bn':
        return 'Bengali';
      case 'gu':
        return 'Gujarati';
      case 'mr':
        return 'Marathi';
      case 'pa':
        return 'Punjabi';
      default:
        return lang.toUpperCase();
    }
  }
}

@JsonSerializable()
class ScriptureVerse {
  ScriptureVerse({
    required this.id,
    required this.sourceId,
    required this.chapter,
    required this.verse,
    required this.textOriginal,
    required this.textTranslation,
    this.audioUrl,
  });

  factory ScriptureVerse.fromJson(Map<String, dynamic> json) => _$ScriptureVerseFromJson(json);

  final int id;
  final int sourceId;
  final int chapter;
  final int verse;
  final String textOriginal;
  final String textTranslation;
  final String? audioUrl;

  Map<String, dynamic> toJson() => _$ScriptureVerseToJson(this);

  /// Get verse reference
  String get reference => 'Chapter $chapter, Verse $verse';

  /// Get short reference
  String get shortReference => '$chapter.$verse';

  /// Get formatted verse
  String get formattedVerse {
    return '$textTranslation\n\n— $reference';
  }

  /// Check if audio is available
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
}

@JsonSerializable()
class GitaVerse {
  GitaVerse({
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.translation,
    this.transliteration,
    this.audioUrl,
    this.commentary,
  });

  factory GitaVerse.fromJson(Map<String, dynamic> json) => _$GitaVerseFromJson(json);

  final int chapter;
  final int verse;
  final String sanskrit;
  final String translation;
  final String? transliteration;
  final String? audioUrl;
  final String? commentary;

  Map<String, dynamic> toJson() => _$GitaVerseToJson(this);

  /// Get verse reference
  String get reference => 'Bhagavad Gita $chapter.$verse';

  /// Get short reference
  String get shortReference => 'BG $chapter.$verse';

  /// Get formatted verse with reference
  String get formattedVerse {
    final buffer = StringBuffer();
    buffer.writeln(translation);
    if (transliteration != null) {
      buffer.writeln('\n$transliteration');
    }
    buffer.writeln('\n— $reference');
    return buffer.toString();
  }

  /// Get chapter title
  String get chapterTitle {
    const chapterTitles = {
      1: 'Arjuna\'s Despondency',
      2: 'Sankhya Yoga',
      3: 'Karma Yoga',
      4: 'Jnana Yoga',
      5: 'Karma Sannyasa Yoga',
      6: 'Dhyana Yoga',
      7: 'Vijnana Yoga',
      8: 'Akshara Brahma Yoga',
      9: 'Raja Vidya Yoga',
      10: 'Vibhuti Yoga',
      11: 'Vishvarupa Darshana Yoga',
      12: 'Bhakti Yoga',
      13: 'Kshetra Kshetrajna Yoga',
      14: 'Guna Traya Vibhaga Yoga',
      15: 'Purushottama Yoga',
      16: 'Daivasura Sampad Vibhaga Yoga',
      17: 'Shraddha Traya Vibhaga Yoga',
      18: 'Moksha Sannyasa Yoga',
    };
    return chapterTitles[chapter] ?? 'Chapter $chapter';
  }

  /// Get chapter summary
  String get chapterSummary {
    const chapterSummaries = {
      1: 'Arjuna is overcome with grief and refuses to fight in the great war.',
      2: 'Krishna teaches Arjuna about the eternal nature of the soul and duty.',
      3: 'Krishna explains the path of selfless action and service.',
      4: 'Krishna reveals the ancient nature of yoga and the path of knowledge.',
      5: 'Krishna explains the path of renunciation and selfless action.',
      6: 'Krishna teaches about meditation and self-control.',
      7: 'Krishna reveals his divine nature and the path of devotion.',
      8: 'Krishna explains the nature of the supreme and the path to liberation.',
      9: 'Krishna teaches the royal secret of devotion and surrender.',
      10: 'Krishna reveals his divine glories and manifestations.',
      11: 'Krishna shows Arjuna his universal form.',
      12: 'Krishna explains the path of devotion and love.',
      13: 'Krishna teaches about the field and the knower of the field.',
      14: 'Krishna explains the three gunas and their influence.',
      15: 'Krishna describes the eternal tree and the supreme person.',
      16: 'Krishna explains the divine and demonic natures.',
      17: 'Krishna teaches about faith and the three types of austerity.',
      18: 'Krishna summarizes the entire teaching and the path to liberation.',
    };
    return chapterSummaries[chapter] ?? 'A chapter of the Bhagavad Gita.';
  }
}

@JsonSerializable()
class WisdomItem {
  WisdomItem({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.durationMin,
    required this.ambiance,
  });

  factory WisdomItem.fromJson(Map<String, dynamic> json) => _$WisdomItemFromJson(json);

  final int id;
  final String category; // 'strategy', 'discipline', 'mindset'
  final String title;
  final String body;
  final int durationMin;
  final Map<String, dynamic> ambiance;

  Map<String, dynamic> toJson() => _$WisdomItemToJson(this);

  /// Get category display name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'strategy':
        return 'Strategy';
      case 'discipline':
        return 'Discipline';
      case 'mindset':
        return 'Mindset';
      default:
        return category.toUpperCase();
    }
  }

  /// Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'strategy':
        return '🎯';
      case 'discipline':
        return '💪';
      case 'mindset':
        return '🧠';
      default:
        return '📚';
    }
  }

  /// Get category color
  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'strategy':
        return '#2196F3'; // Blue
      case 'discipline':
        return '#FF9800'; // Orange
      case 'mindset':
        return '#9C27B0'; // Purple
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationMin < 60) {
      return '${durationMin}m';
    } else {
      final hours = durationMin ~/ 60;
      final minutes = durationMin % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}m';
      }
    }
  }

  /// Get sound preference
  String? get soundPreference => ambiance['sound'] as String?;

  /// Get light preference
  String? get lightPreference => ambiance['light'] as String?;

  /// Get formatted ambiance
  String get formattedAmbiance {
    final parts = <String>[];
    if (soundPreference != null) {
      parts.add('Sound: $soundPreference');
    }
    if (lightPreference != null) {
      parts.add('Light: $lightPreference');
    }
    return parts.join(' • ');
  }
}

@JsonSerializable()
class DailyWisdom {
  DailyWisdom({
    required this.date,
    required this.wisdomItem,
    this.completedAt,
    this.notes,
  });

  factory DailyWisdom.fromJson(Map<String, dynamic> json) => _$DailyWisdomFromJson(json);

  final DateTime date;
  final WisdomItem wisdomItem;
  final DateTime? completedAt;
  final String? notes;

  Map<String, dynamic> toJson() => _$DailyWisdomToJson(this);

  /// Check if completed
  bool get isCompleted => completedAt != null;

  /// Get completion status
  String get completionStatus {
    if (isCompleted) {
      return 'Completed';
    } else {
      return 'Pending';
    }
  }

  /// Get completion emoji
  String get completionEmoji {
    return isCompleted ? '✅' : '⏳';
  }
}

@JsonSerializable()
class SpiritualProgress {
  SpiritualProgress({
    required this.period,
    required this.totalWisdomItems,
    required this.completedItems,
    required this.totalVerses,
    required this.readVerses,
    required this.streak,
    required this.insights,
  });

  factory SpiritualProgress.fromJson(Map<String, dynamic> json) => _$SpiritualProgressFromJson(json);

  final String period; // 'week', 'month', 'year'
  final int totalWisdomItems;
  final int completedItems;
  final int totalVerses;
  final int readVerses;
  final int streak;
  final List<String> insights;

  Map<String, dynamic> toJson() => _$SpiritualProgressToJson(this);

  /// Get wisdom completion rate
  double get wisdomCompletionRate {
    if (totalWisdomItems == 0) return 0.0;
    return completedItems / totalWisdomItems;
  }

  /// Get verse completion rate
  double get verseCompletionRate {
    if (totalVerses == 0) return 0.0;
    return readVerses / totalVerses;
  }

  /// Get overall progress
  double get overallProgress {
    return (wisdomCompletionRate + verseCompletionRate) / 2.0;
  }

  /// Get progress percentage
  int get progressPercentage {
    return (overallProgress * 100).round();
  }

  /// Get streak emoji
  String get streakEmoji {
    if (streak >= 30) return '🔥';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '💫';
    if (streak >= 3) return '✨';
    return '🌟';
  }

  /// Get progress insights
  List<String> get progressInsights {
    final insights = <String>[];
    
    if (streak >= 30) {
      insights.add('Amazing! You\'ve maintained a $streak-day streak!');
    } else if (streak >= 14) {
      insights.add('Great job! You\'re building a strong spiritual practice.');
    } else if (streak >= 7) {
      insights.add('Good progress! Keep up the momentum.');
    } else if (streak >= 3) {
      insights.add('You\'re getting started! Every day counts.');
    } else {
      insights.add('Start your spiritual journey today!');
    }
    
    if (wisdomCompletionRate >= 0.8) {
      insights.add('You\'re consistently engaging with wisdom content.');
    }
    
    if (verseCompletionRate >= 0.8) {
      insights.add('You\'re regularly reading sacred texts.');
    }
    
    return insights;
  }
}

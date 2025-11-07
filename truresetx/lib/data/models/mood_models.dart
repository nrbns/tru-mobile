import 'package:json_annotation/json_annotation.dart';

part 'mood_models.g.dart';

@JsonSerializable()
class MoodLog {
  MoodLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.who5Raw,
    required this.who5Pct,
    required this.energy,
    required this.stress,
    this.notes,
    this.createdAt,
  });

  factory MoodLog.fromJson(Map<String, dynamic> json) =>
      _$MoodLogFromJson(json);

  final int id;
  final String userId;
  final DateTime date;
  final int who5Raw;
  final int who5Pct;
  final int energy;
  final int stress;
  final String? notes;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$MoodLogToJson(this);

  /// Get overall mood score (0-100)
  int get overallMoodScore => who5Pct;

  /// Get mood category
  MoodCategory get moodCategory {
    if (who5Pct >= 80) return MoodCategory.excellent;
    if (who5Pct >= 60) return MoodCategory.good;
    if (who5Pct >= 40) return MoodCategory.fair;
    if (who5Pct >= 20) return MoodCategory.poor;
    return MoodCategory.veryPoor;
  }

  /// Get energy level category
  EnergyLevel get energyLevel {
    if (energy >= 8) return EnergyLevel.veryHigh;
    if (energy >= 6) return EnergyLevel.high;
    if (energy >= 4) return EnergyLevel.moderate;
    if (energy >= 2) return EnergyLevel.low;
    return EnergyLevel.veryLow;
  }

  /// Get stress level category
  StressLevel get stressLevel {
    if (stress >= 8) return StressLevel.veryHigh;
    if (stress >= 6) return StressLevel.high;
    if (stress >= 4) return StressLevel.moderate;
    if (stress >= 2) return StressLevel.low;
    return StressLevel.veryLow;
  }

  /// Get mood color for UI
  String get moodColor {
    switch (moodCategory) {
      case MoodCategory.excellent:
        return '#4CAF50'; // Green
      case MoodCategory.good:
        return '#8BC34A'; // Light Green
      case MoodCategory.fair:
        return '#FFC107'; // Amber
      case MoodCategory.poor:
        return '#FF9800'; // Orange
      case MoodCategory.veryPoor:
        return '#F44336'; // Red
    }
  }

  /// Get mood emoji
  String get moodEmoji {
    switch (moodCategory) {
      case MoodCategory.excellent:
        return '😄';
      case MoodCategory.good:
        return '😊';
      case MoodCategory.fair:
        return '😐';
      case MoodCategory.poor:
        return '😔';
      case MoodCategory.veryPoor:
        return '😢';
    }
  }
}

enum MoodCategory {
  excellent,
  good,
  fair,
  poor,
  veryPoor,
}

extension MoodCategoryX on MoodCategory {
  String get emoji {
    switch (this) {
      case MoodCategory.excellent:
        return '😄';
      case MoodCategory.good:
        return '😊';
      case MoodCategory.fair:
        return '😐';
      case MoodCategory.poor:
        return '😔';
      case MoodCategory.veryPoor:
        return '😢';
    }
  }
}

enum EnergyLevel {
  veryHigh,
  high,
  moderate,
  low,
  veryLow,
}

enum StressLevel {
  veryHigh,
  high,
  moderate,
  low,
  veryLow,
}

@JsonSerializable()
class Who5Item {
  Who5Item({
    required this.id,
    required this.question,
    required this.scale,
    this.description,
  });

  factory Who5Item.fromJson(Map<String, dynamic> json) =>
      _$Who5ItemFromJson(json);

  final int id;
  final String question;
  final List<int> scale; // [0, 1, 2, 3, 4, 5]
  final String? description;

  Map<String, dynamic> toJson() => _$Who5ItemToJson(this);

  /// Get scale labels
  List<String> get scaleLabels {
    return scale.map((value) => _getScaleLabel(value)).toList();
  }

  String _getScaleLabel(int value) {
    switch (value) {
      case 0:
        return 'At no time';
      case 1:
        return 'Some of the time';
      case 2:
        return 'Less than half of the time';
      case 3:
        return 'More than half of the time';
      case 4:
        return 'Most of the time';
      case 5:
        return 'All of the time';
      default:
        return 'Unknown';
    }
  }
}

@JsonSerializable()
class Who5Assessment {
  Who5Assessment({
    required this.items,
    required this.totalScore,
    required this.percentage,
    required this.category,
    this.completedAt,
  });

  factory Who5Assessment.fromJson(Map<String, dynamic> json) =>
      _$Who5AssessmentFromJson(json);

  final List<Who5Item> items;
  final int totalScore;
  final int percentage;
  final MoodCategory category;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => _$Who5AssessmentToJson(this);

  /// Get assessment insights
  List<String> get insights {
    final insights = <String>[];

    if (percentage >= 80) {
      insights.add('You\'re feeling great! Keep up the positive mindset.');
    } else if (percentage >= 60) {
      insights
          .add('You\'re doing well overall. Consider what\'s working for you.');
    } else if (percentage >= 40) {
      insights.add(
          'You might be going through a challenging time. Remember, this too shall pass.');
    } else if (percentage >= 20) {
      insights.add(
          'It seems like you\'re struggling. Consider reaching out for support.');
    } else {
      insights.add(
          'Please consider speaking with a healthcare professional about your wellbeing.');
    }

    return insights;
  }

  /// Get recommendations
  List<String> get recommendations {
    final recommendations = <String>[];

    if (percentage < 60) {
      recommendations.add('Try some gentle exercise or a short walk');
      recommendations.add('Practice deep breathing or meditation');
      recommendations.add('Connect with friends or family');
      recommendations.add('Get adequate sleep (7-9 hours)');
    }

    if (percentage < 40) {
      recommendations.add('Consider professional mental health support');
      recommendations.add('Maintain a regular routine');
      recommendations.add('Limit alcohol and caffeine');
      recommendations.add('Practice gratitude journaling');
    }

    return recommendations;
  }
}

@JsonSerializable()
class MoodSummary {
  MoodSummary({
    required this.week,
    required this.averageMood,
    required this.moodTrend,
    required this.energyTrend,
    required this.stressTrend,
    required this.dailyLogs,
    required this.insights,
    required this.recommendations,
  });

  factory MoodSummary.fromJson(Map<String, dynamic> json) =>
      _$MoodSummaryFromJson(json);

  final String week;
  final double averageMood;
  final String moodTrend; // 'improving', 'stable', 'declining'
  final String energyTrend;
  final String stressTrend;
  final List<MoodLog> dailyLogs;
  final List<String> insights;
  final List<String> recommendations;

  Map<String, dynamic> toJson() => _$MoodSummaryToJson(this);

  /// Get trend emoji
  String get trendEmoji {
    switch (moodTrend) {
      case 'improving':
        return '📈';
      case 'stable':
        return '➡️';
      case 'declining':
        return '📉';
      default:
        return '❓';
    }
  }

  /// Get trend color
  String get trendColor {
    switch (moodTrend) {
      case 'improving':
        return '#4CAF50'; // Green
      case 'stable':
        return '#2196F3'; // Blue
      case 'declining':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get completion rate
  double get completionRate {
    return dailyLogs.length / 7.0; // 7 days in a week
  }

  /// Get best day
  MoodLog? get bestDay {
    if (dailyLogs.isEmpty) return null;
    return dailyLogs.reduce((a, b) => a.who5Pct > b.who5Pct ? a : b);
  }

  /// Get worst day
  MoodLog? get worstDay {
    if (dailyLogs.isEmpty) return null;
    return dailyLogs.reduce((a, b) => a.who5Pct < b.who5Pct ? a : b);
  }
}

@JsonSerializable()
class MoodInsight {
  MoodInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    this.actionItems,
  });

  factory MoodInsight.fromJson(Map<String, dynamic> json) =>
      _$MoodInsightFromJson(json);

  final String type; // 'pattern', 'trend', 'recommendation', 'warning'
  final String title;
  final String description;
  final String severity; // 'low', 'medium', 'high'
  final List<String>? actionItems;

  Map<String, dynamic> toJson() => _$MoodInsightToJson(this);

  /// Get severity color
  String get severityColor {
    switch (severity) {
      case 'low':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'high':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get severity icon
  String get severityIcon {
    switch (severity) {
      case 'low':
        return 'ℹ️';
      case 'medium':
        return '⚠️';
      case 'high':
        return '🚨';
      default:
        return '❓';
    }
  }
}

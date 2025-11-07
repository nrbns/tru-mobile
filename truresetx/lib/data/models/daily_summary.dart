import 'package:uuid/uuid.dart';

/// Daily Summary model for TruResetX v1.0
class DailySummary {

  DailySummary({
    required this.id,
    required this.userId,
    required this.date,
    required this.summaryText,
    required this.wellnessScore,
    required this.achievements,
    required this.recommendations,
    this.moodTrend,
    this.energyTrend,
    required this.createdAt,
  });

  /// Create a new daily summary
  factory DailySummary.create({
    required String userId,
    DateTime? date,
    required String summaryText,
    required double wellnessScore,
    required List<String> achievements,
    required List<String> recommendations,
    String? moodTrend,
    String? energyTrend,
  }) {
    return DailySummary(
      id: const Uuid().v4(),
      userId: userId,
      date: date ?? DateTime.now(),
      summaryText: summaryText,
      wellnessScore: wellnessScore,
      achievements: achievements,
      recommendations: recommendations,
      moodTrend: moodTrend,
      energyTrend: energyTrend,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      summaryText: json['summary_text'],
      wellnessScore: json['wellness_score'].toDouble(),
      achievements: List<String>.from(json['achievements']),
      recommendations: List<String>.from(json['recommendations']),
      moodTrend: json['mood_trend'],
      energyTrend: json['energy_trend'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String userId;
  final DateTime date;
  final String summaryText;
  final double wellnessScore; // 0.00 to 1.00
  final List<String> achievements;
  final List<String> recommendations;
  final String? moodTrend;
  final String? energyTrend;
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'summary_text': summaryText,
      'wellness_score': wellnessScore,
      'achievements': achievements,
      'recommendations': recommendations,
      'mood_trend': moodTrend,
      'energy_trend': energyTrend,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  DailySummary copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? summaryText,
    double? wellnessScore,
    List<String>? achievements,
    List<String>? recommendations,
    String? moodTrend,
    String? energyTrend,
    DateTime? createdAt,
  }) {
    return DailySummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      summaryText: summaryText ?? this.summaryText,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      achievements: achievements ?? this.achievements,
      recommendations: recommendations ?? this.recommendations,
      moodTrend: moodTrend ?? this.moodTrend,
      energyTrend: energyTrend ?? this.energyTrend,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get wellness score as percentage
  int get wellnessScorePercentage => (wellnessScore * 100).round();

  /// Get wellness level
  String get wellnessLevel {
    if (wellnessScore >= 0.8) return 'Excellent';
    if (wellnessScore >= 0.6) return 'Good';
    if (wellnessScore >= 0.4) return 'Fair';
    return 'Poor';
  }

  /// Get wellness level emoji
  String get wellnessLevelEmoji {
    switch (wellnessLevel) {
      case 'Excellent':
        return '🌟';
      case 'Good':
        return '😊';
      case 'Fair':
        return '😐';
      case 'Poor':
        return '😔';
      default:
        return '❓';
    }
  }

  /// Get wellness level color
  String get wellnessLevelColor {
    switch (wellnessLevel) {
      case 'Excellent':
        return 'green';
      case 'Good':
        return 'blue';
      case 'Fair':
        return 'orange';
      case 'Poor':
        return 'red';
      default:
        return 'gray';
    }
  }

  /// Get mood trend emoji
  String get moodTrendEmoji {
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

  /// Get energy trend emoji
  String get energyTrendEmoji {
    switch (energyTrend) {
      case 'increasing':
        return '⚡';
      case 'stable':
        return '🔋';
      case 'decreasing':
        return '🔌';
      default:
        return '❓';
    }
  }

  /// Get date display text
  String get dateDisplayText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final summaryDate = DateTime(date.year, date.month, date.day);
    
    if (summaryDate == today) return 'Today';
    if (summaryDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (summaryDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get relative date display text
  String get relativeDateDisplayText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final summaryDate = DateTime(date.year, date.month, date.day);
    final difference = summaryDate.difference(today).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == -1) return 'Yesterday';
    if (difference == 1) return 'Tomorrow';
    if (difference > 0) return 'In $difference days';
    return '${-difference} days ago';
  }

  /// Get achievements count
  int get achievementsCount => achievements.length;

  /// Get recommendations count
  int get recommendationsCount => recommendations.length;

  /// Get achievements display text
  String get achievementsDisplayText {
    if (achievements.isEmpty) return 'No achievements today';
    if (achievements.length == 1) return '1 achievement';
    return '${achievements.length} achievements';
  }

  /// Get recommendations display text
  String get recommendationsDisplayText {
    if (recommendations.isEmpty) return 'No recommendations';
    if (recommendations.length == 1) return '1 recommendation';
    return '${recommendations.length} recommendations';
  }

  /// Get summary preview (first 100 characters)
  String get summaryPreview {
    if (summaryText.length <= 100) return summaryText;
    return '${summaryText.substring(0, 100)}...';
  }

  /// Get mood trend display text
  String get moodTrendDisplayText {
    switch (moodTrend) {
      case 'improving':
        return 'Mood is improving';
      case 'stable':
        return 'Mood is stable';
      case 'declining':
        return 'Mood is declining';
      default:
        return 'Mood trend unknown';
    }
  }

  /// Get energy trend display text
  String get energyTrendDisplayText {
    switch (energyTrend) {
      case 'increasing':
        return 'Energy is increasing';
      case 'stable':
        return 'Energy is stable';
      case 'decreasing':
        return 'Energy is decreasing';
      default:
        return 'Energy trend unknown';
    }
  }

  /// Get overall trend
  String get overallTrend {
    if (moodTrend == 'improving' && energyTrend == 'increasing') return 'excellent';
    if (moodTrend == 'improving' || energyTrend == 'increasing') return 'good';
    if (moodTrend == 'stable' && energyTrend == 'stable') return 'stable';
    if (moodTrend == 'declining' || energyTrend == 'decreasing') return 'concerning';
    return 'unknown';
  }

  /// Get overall trend emoji
  String get overallTrendEmoji {
    switch (overallTrend) {
      case 'excellent':
        return '🚀';
      case 'good':
        return '📈';
      case 'stable':
        return '➡️';
      case 'concerning':
        return '⚠️';
      default:
        return '❓';
    }
  }

  /// Get overall trend display text
  String get overallTrendDisplayText {
    switch (overallTrend) {
      case 'excellent':
        return 'Excellent progress';
      case 'good':
        return 'Good progress';
      case 'stable':
        return 'Stable progress';
      case 'concerning':
        return 'Needs attention';
      default:
        return 'Trend unknown';
    }
  }

  /// Get priority level
  String get priorityLevel {
    if (wellnessScore < 0.3) return 'High';
    if (wellnessScore < 0.5) return 'Medium';
    return 'Low';
  }

  /// Get priority color
  String get priorityColor {
    switch (priorityLevel) {
      case 'High':
        return 'red';
      case 'Medium':
        return 'orange';
      case 'Low':
        return 'green';
      default:
        return 'gray';
    }
  }

  /// Get summary category
  String get summaryCategory {
    if (wellnessScore >= 0.8) return 'excellent';
    if (wellnessScore >= 0.6) return 'good';
    if (wellnessScore >= 0.4) return 'fair';
    return 'poor';
  }

  /// Get summary category emoji
  String get summaryCategoryEmoji {
    switch (summaryCategory) {
      case 'excellent':
        return '🌟';
      case 'good':
        return '😊';
      case 'fair':
        return '😐';
      case 'poor':
        return '😔';
      default:
        return '❓';
    }
  }

  /// Get summary insights
  List<String> get summaryInsights {
    final insights = <String>[];
    
    if (achievements.isNotEmpty) {
      insights.add('You achieved ${achievements.length} goal${achievements.length > 1 ? 's' : ''} today');
    }
    
    if (wellnessScore >= 0.8) {
      insights.add('You had an excellent wellness day');
    } else if (wellnessScore >= 0.6) {
      insights.add('You had a good wellness day');
    } else if (wellnessScore < 0.4) {
      insights.add('Your wellness needs attention');
    }
    
    if (moodTrend == 'improving') {
      insights.add('Your mood is trending upward');
    } else if (moodTrend == 'declining') {
      insights.add('Your mood needs support');
    }
    
    if (energyTrend == 'increasing') {
      insights.add('Your energy levels are rising');
    } else if (energyTrend == 'decreasing') {
      insights.add('Your energy levels are dropping');
    }
    
    return insights;
  }

  /// Get action items
  List<String> get actionItems {
    final actions = <String>[];
    
    if (recommendations.isNotEmpty) {
      actions.addAll(recommendations);
    }
    
    if (wellnessScore < 0.5) {
      actions.add('Consider a mindfulness practice');
    }
    
    if (moodTrend == 'declining') {
      actions.add('Try a mood-boosting activity');
    }
    
    if (energyTrend == 'decreasing') {
      actions.add('Get adequate rest and nutrition');
    }
    
    return actions;
  }

  /// Get summary statistics
  Map<String, dynamic> get statistics {
    return {
      'wellness_score': wellnessScore,
      'wellness_score_percentage': wellnessScorePercentage,
      'wellness_level': wellnessLevel,
      'achievements_count': achievementsCount,
      'recommendations_count': recommendationsCount,
      'mood_trend': moodTrend,
      'energy_trend': energyTrend,
      'overall_trend': overallTrend,
      'priority_level': priorityLevel,
      'summary_category': summaryCategory,
    };
  }

  /// Validate summary data
  bool get isValid {
    return summaryText.trim().isNotEmpty &&
           wellnessScore >= 0.0 && wellnessScore <= 1.0 &&
           (moodTrend == null || ['improving', 'stable', 'declining'].contains(moodTrend)) &&
           (energyTrend == null || ['increasing', 'stable', 'decreasing'].contains(energyTrend));
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (summaryText.trim().isEmpty) {
      errors.add('Summary text cannot be empty');
    }
    
    if (wellnessScore < 0.0 || wellnessScore > 1.0) {
      errors.add('Wellness score must be between 0.0 and 1.0');
    }
    
    if (moodTrend != null && !['improving', 'stable', 'declining'].contains(moodTrend)) {
      errors.add('Invalid mood trend');
    }
    
    if (energyTrend != null && !['increasing', 'stable', 'decreasing'].contains(energyTrend)) {
      errors.add('Invalid energy trend');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'DailySummary(id: $id, date: $date, wellnessScore: $wellnessScorePercentage%, achievements: $achievementsCount, recommendations: $recommendationsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailySummary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

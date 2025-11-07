/// Dream Analyzer - Symbolic interpretation
class DreamEntry {
  final String id;
  final String userId;
  final String dreamText;
  final DateTime loggedAt;
  final Map<String, dynamic>? analysis;
  final String? interpretation; // Spiritual or psychological

  DreamEntry({
    required this.id,
    required this.userId,
    required this.dreamText,
    required this.loggedAt,
    this.analysis,
    this.interpretation,
  });

  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dreamText: json['dreamText'] as String,
      loggedAt: json['loggedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['loggedAt'] as int)
          : DateTime.now(),
      analysis: json['analysis'] as Map<String, dynamic>?,
      interpretation: json['interpretation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dreamText': dreamText,
      'loggedAt': loggedAt.millisecondsSinceEpoch,
      'analysis': analysis,
      'interpretation': interpretation,
    };
  }
}

class DreamInterpretation {
  final String symbolicMeaning;
  final String psychologicalMeaning;
  final String? spiritualMeaning;
  final List<String> themes;
  final String suggestedAction;

  DreamInterpretation({
    required this.symbolicMeaning,
    required this.psychologicalMeaning,
    this.spiritualMeaning,
    required this.themes,
    required this.suggestedAction,
  });
}


/// Rep Metrics model for tracking individual rep performance in AR workouts
class RepMetrics {

  RepMetrics({
    required this.id,
    required this.setSessionId,
    required this.repIndex,
    required this.jointAngles,
    required this.rangeScore,
    required this.stabilityScore,
    required this.repScore,
    required this.painFlag,
    required this.timestamp,
    required this.additionalMetrics,
  });

  factory RepMetrics.fromJson(Map<String, dynamic> json) {
    return RepMetrics(
      id: json['id'],
      setSessionId: json['set_session_id'],
      repIndex: json['rep_index'],
      jointAngles: Map<String, dynamic>.from(json['joint_angles']),
      rangeScore: json['range_score'].toDouble(),
      stabilityScore: json['stability_score'].toDouble(),
      repScore: json['rep_score'].toDouble(),
      painFlag: json['pain_flag'],
      timestamp: DateTime.parse(json['timestamp']),
      additionalMetrics: Map<String, dynamic>.from(json['additional_metrics']),
    );
  }
  final String id;
  final String setSessionId;
  final int repIndex;
  final Map<String, dynamic> jointAngles;
  final double rangeScore;
  final double stabilityScore;
  final double repScore;
  final bool painFlag;
  final DateTime timestamp;
  final Map<String, dynamic> additionalMetrics;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'set_session_id': setSessionId,
      'rep_index': repIndex,
      'joint_angles': jointAngles,
      'range_score': rangeScore,
      'stability_score': stabilityScore,
      'rep_score': repScore,
      'pain_flag': painFlag,
      'timestamp': timestamp.toIso8601String(),
      'additional_metrics': additionalMetrics,
    };
  }
}

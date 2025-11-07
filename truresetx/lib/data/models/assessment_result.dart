/// Assessment Result model for movement and wellness assessments
class AssessmentResult {

  AssessmentResult({
    required this.id,
    required this.userId,
    required this.date,
    required this.overallGrade,
    required this.limitations,
    required this.injuryRisks,
    required this.recommendations,
    required this.progressionPlan,
    required this.testResults,
    required this.metadata,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      overallGrade: json['overall_grade'],
      limitations: List<String>.from(json['limitations']),
      injuryRisks: List<String>.from(json['injury_risks']),
      recommendations: Map<String, String>.from(json['recommendations']),
      progressionPlan: Map<String, String>.from(json['progression_plan']),
      testResults: (json['test_results'] as List)
          .map((t) => MovementTestResult.fromJson(t))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
  final String id;
  final String userId;
  final DateTime date;
  final String overallGrade; // A, B, C, D
  final List<String> limitations;
  final List<String> injuryRisks;
  final Map<String, String> recommendations;
  final Map<String, String> progressionPlan;
  final List<MovementTestResult> testResults;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'overall_grade': overallGrade,
      'limitations': limitations,
      'injury_risks': injuryRisks,
      'recommendations': recommendations,
      'progression_plan': progressionPlan,
      'test_results': testResults.map((t) => t.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

/// Movement Test Result model
class MovementTestResult {

  MovementTestResult({
    required this.test,
    required this.score,
    required this.grade,
    required this.limitations,
    required this.recommendations,
    required this.jointAngles,
    required this.metrics,
  });

  factory MovementTestResult.fromJson(Map<String, dynamic> json) {
    return MovementTestResult(
      test: json['test'],
      score: json['score'].toDouble(),
      grade: json['grade'],
      limitations: List<String>.from(json['limitations']),
      recommendations: List<String>.from(json['recommendations']),
      jointAngles: Map<String, double>.from(json['joint_angles']),
      metrics: Map<String, dynamic>.from(json['metrics']),
    );
  }
  final String test;
  final double score;
  final String grade;
  final List<String> limitations;
  final List<String> recommendations;
  final Map<String, double> jointAngles;
  final Map<String, dynamic> metrics;

  Map<String, dynamic> toJson() {
    return {
      'test': test,
      'score': score,
      'grade': grade,
      'limitations': limitations,
      'recommendations': recommendations,
      'joint_angles': jointAngles,
      'metrics': metrics,
    };
  }
}

/// Rep Metrics model for tracking individual rep performance
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

/// Movement Limits model for tracking user's movement capabilities
class MovementLimits {

  MovementLimits({
    required this.userId,
    required this.hipExtensionDegrees,
    required this.ankleDorsiflexionDegrees,
    required this.thoracicExtensionDegrees,
    required this.leftRightDifferencePercent,
    required this.updatedAt,
    required this.additionalLimits,
  });

  factory MovementLimits.fromJson(Map<String, dynamic> json) {
    return MovementLimits(
      userId: json['user_id'],
      hipExtensionDegrees: json['hip_extension_degrees'].toDouble(),
      ankleDorsiflexionDegrees: json['ankle_dorsiflexion_degrees'].toDouble(),
      thoracicExtensionDegrees: json['thoracic_extension_degrees'].toDouble(),
      leftRightDifferencePercent: json['left_right_difference_percent'].toDouble(),
      updatedAt: DateTime.parse(json['updated_at']),
      additionalLimits: Map<String, dynamic>.from(json['additional_limits']),
    );
  }
  final String userId;
  final double hipExtensionDegrees;
  final double ankleDorsiflexionDegrees;
  final double thoracicExtensionDegrees;
  final double leftRightDifferencePercent;
  final DateTime updatedAt;
  final Map<String, dynamic> additionalLimits;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'hip_extension_degrees': hipExtensionDegrees,
      'ankle_dorsiflexion_degrees': ankleDorsiflexionDegrees,
      'thoracic_extension_degrees': thoracicExtensionDegrees,
      'left_right_difference_percent': leftRightDifferencePercent,
      'updated_at': updatedAt.toIso8601String(),
      'additional_limits': additionalLimits,
    };
  }
}

/// Program Block model for workout periodization
class ProgramBlock {

  ProgramBlock({
    required this.id,
    required this.userId,
    required this.blockNumber,
    required this.startDate,
    required this.focus,
    required this.loadIndex,
    required this.parameters,
  });

  factory ProgramBlock.fromJson(Map<String, dynamic> json) {
    return ProgramBlock(
      id: json['id'],
      userId: json['user_id'],
      blockNumber: json['block_number'],
      startDate: DateTime.parse(json['start_date']),
      focus: json['focus'],
      loadIndex: json['load_index'].toDouble(),
      parameters: Map<String, dynamic>.from(json['parameters']),
    );
  }
  final String id;
  final String userId;
  final int blockNumber;
  final DateTime startDate;
  final String focus;
  final double loadIndex;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'block_number': blockNumber,
      'start_date': startDate.toIso8601String(),
      'focus': focus,
      'load_index': loadIndex,
      'parameters': parameters,
    };
  }
}

/// Set Feedback model for tracking workout set performance
class SetFeedback {

  SetFeedback({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.setNumber,
    required this.repQualityAverage,
    required this.rpe,
    required this.painFlag,
    this.notes,
  });

  factory SetFeedback.fromJson(Map<String, dynamic> json) {
    return SetFeedback(
      id: json['id'],
      workoutId: json['workout_id'],
      exerciseId: json['exercise_id'],
      setNumber: json['set_number'],
      repQualityAverage: json['rep_quality_average'].toDouble(),
      rpe: json['rpe'].toDouble(),
      painFlag: json['pain_flag'],
      notes: json['notes'],
    );
  }
  final String id;
  final String workoutId;
  final String exerciseId;
  final int setNumber;
  final double repQualityAverage;
  final double rpe; // Rate of Perceived Exertion
  final bool painFlag;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'rep_quality_average': repQualityAverage,
      'rpe': rpe,
      'pain_flag': painFlag,
      'notes': notes,
    };
  }
}

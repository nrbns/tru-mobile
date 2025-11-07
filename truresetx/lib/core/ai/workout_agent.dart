import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:uuid/uuid.dart';

import '../services/ai_service.dart';
import '../services/camera_service.dart';
import '../../data/models/workout_plan.dart';
import '../../data/models/assessment_result.dart';
import '../../data/models/rep_metrics.dart' as rep_models;

/// AR Workout Agent - Specialized AI for workout planning and AR coaching
class WorkoutAgent {
  WorkoutAgent({
    required AIService aiService,
    required CameraService cameraService,
  })  : _aiService = aiService,
        _cameraService = cameraService;
  final AIService _aiService;
  final CameraService _cameraService;
  final _uuidGen = const Uuid();

  // Pose/Session lifecycle
  bool _isListening = false;
  Timer? _poseDebounceTimer;
  final Duration _poseDebounce = const Duration(milliseconds: 250);
  // processing guard removed for now; debounce/timers handle rate limiting
  final Map<String, ARSetSession> _activeSessions = {};

  /// Create or update workout plan based on assessment and user state
  Future<WorkoutPlan> createOrUpdateWorkoutPlan({
    required String userId,
    required List<String> goals,
    required Map<String, dynamic> constraints,
    required AssessmentResult? assessment,
    required List<String> calendarAvailability,
  }) async {
    final prompt = '''
    Create a personalized workout plan based on the following:
    
    User Goals: ${goals.join(', ')}
    Constraints: ${jsonEncode(constraints)}
    Assessment Results: ${assessment?.toJson() ?? 'No assessment available'}
    Available Time Slots: ${calendarAvailability.join(', ')}
    
    Generate a 4-week progressive plan with:
    1. Movement assessment recommendations
    2. Weekly progression (volume ↑, intensity ↑, deload)
    3. Exercise selection based on movement limitations
    4. Equipment requirements
    5. Safety considerations
    
    Return as JSON:
    {
      "plan_id": "unique_id",
      "user_id": "$userId",
      "goals": ["goal1", "goal2"],
      "duration_weeks": 4,
      "blocks": [
        {
          "week": 1,
          "focus": "movement_preparation",
          "sessions": [
            {
              "day": "Monday",
              "duration_minutes": 45,
              "type": "strength",
              "exercises": [
                {
                  "name": "Air Squat Assessment",
                  "sets": 3,
                  "reps": 10,
                  "tempo": "3-1-3-1",
                  "rest_seconds": 90,
                  "ar_guidance": true,
                  "form_cues": ["knees out", "chest up", "full depth"]
                }
              ]
            }
          ]
        }
      ],
      "assessment_schedule": {
        "initial": true,
        "weekly_retest": ["Air Squat", "Hip Hinge"],
        "monthly_full": true
      },
      "safety_guidelines": {
        "pain_free_only": true,
        "progression_cap": "10%_weekly",
        "deload_triggers": ["fatigue_high", "form_degradation"]
      }
    }
    ''';

    final response = await _aiService.chatCompletion(prompt);
    final planJson = jsonDecode(response);

    return WorkoutPlan.fromJson(planJson);
  }

  /// Start AR set session with pose detection
  Future<ARSetSession> startARSetSession({
    required String exerciseId,
    required int expectedReps,
    required String tempo,
    required String userId,
  }) async {
    // Initialize camera and pose detection
    await _cameraService.initializeCamera();

    final sessionId = _uuidGen.v4();
    final session = ARSetSession(
      id: sessionId,
      exerciseId: exerciseId,
      userId: userId,
      expectedReps: expectedReps,
      tempo: tempo,
      startTime: DateTime.now(),
      repMetrics: <rep_models.RepMetrics>[],
      isActive: true,
    );

    // register session and start shared pose detection
    _activeSessions[session.id] = session;
    _startPoseDetection();

    return session;
  }

  /// Submit rep metrics from computer vision
  Future<void> submitRepMetrics({
    required String setSessionId,
    required int repIndex,
    required Map<String, dynamic> jointAngles,
    required double rangeScore,
    required double stabilityScore,
    required bool painFlag,
  }) async {
    final repScore = _calculateRepScore(rangeScore, stabilityScore, painFlag);

    final metrics = rep_models.RepMetrics(
      id: _uuidGen.v4(),
      setSessionId: setSessionId,
      repIndex: repIndex,
      jointAngles: jointAngles,
      rangeScore: rangeScore,
      stabilityScore: stabilityScore,
      repScore: repScore,
      painFlag: painFlag,
      timestamp: DateTime.now(),
      additionalMetrics: <String, dynamic>{},
    );

    // Store metrics
    await _storeRepMetrics(metrics);

    // Provide real-time feedback
    await _provideRepFeedback(metrics);

    // Append metrics to active session if present
    final session = _activeSessions[setSessionId];
    if (session != null) {
      session.repMetrics.add(metrics);

      // Mark session inactive if we've reached expected reps
      if (session.repMetrics.length >= session.expectedReps) {
        session.isActive = false;
      }

      // If no more active sessions, stop pose detection to conserve resources
      if (!_activeSessions.values.any((s) => s.isActive)) {
        _stopPoseDetection();
      }
    } else {
      print('Warning: received rep metrics for unknown session $setSessionId');
    }
  }

  /// Stop shared pose detection stream
  Future<void> _stopPoseDetection() async {
    _poseDebounceTimer?.cancel();
    _poseDebounceTimer = null;
    if (_isListening) {
      _isListening = false;
      try {
        await _cameraService.stopCameraStream();
      } catch (e) {
        print('Error stopping camera stream: $e');
      }
    }
  }

  /// End an AR set session manually and return collected metrics
  Future<ARSetSession?> endARSetSession(String sessionId) async {
    final session = _activeSessions.remove(sessionId);
    if (session == null) return null;
    session.isActive = false;

    // If no sessions remain, stop pose detection
    if (!_activeSessions.values.any((s) => s.isActive)) {
      await _stopPoseDetection();
    }

    return session;
  }

  /// Perform movement assessment with AR scoring
  Future<AssessmentResult> performMovementAssessment({
    required String userId,
    required List<String> tests,
  }) async {
    final results = <String, MovementTestResult>{};

    for (final test in tests) {
      final testResult = await _performSingleTest(test, userId);
      results[test] = testResult;
    }

    // Generate overall assessment
    final assessment = await _generateAssessment(results, userId);

    return assessment;
  }

  /// Calculate rep quality score
  double _calculateRepScore(
      double rangeScore, double stabilityScore, bool painFlag) {
    if (painFlag) return 0.0; // Pain = automatic failure

    // Weighted scoring: 40% range, 30% stability, 30% symmetry
    const rangeWeight = 0.4;
    const stabilityWeight = 0.3;
    const symmetryWeight = 0.3;

    // Symmetry score would be calculated from left/right differences
    const symmetryScore = 0.8; // Placeholder

    return (rangeScore * rangeWeight) +
        (stabilityScore * stabilityWeight) +
        (symmetryScore * symmetryWeight);
  }

  /// Start (shared) pose detection stream and route poses to active sessions
  void _startPoseDetection() {
    if (_isListening) return;
    _isListening = true;
    _cameraService.startPoseDetection((pose) {
      // Debounce to avoid flooding
      _poseDebounceTimer?.cancel();
      _poseDebounceTimer = Timer(_poseDebounce, () {
        for (final session in _activeSessions.values.where((s) => s.isActive)) {
          _processPoseData(pose, session);
        }
      });
    });
  }

  /// Process pose data and extract metrics
  void _processPoseData(Pose pose, ARSetSession session) {
    // Extract key joint angles
    final jointAngles = _extractJointAngles(pose);

    // Calculate range and stability scores
    final rangeScore = _calculateRangeScore(jointAngles, session.exerciseId);
    final stabilityScore = _calculateStabilityScore(jointAngles);

    // Detect pain indicators (compensation patterns)
    final painFlag = _detectPainIndicators(jointAngles);

    // Submit metrics
    submitRepMetrics(
      setSessionId: session.id,
      repIndex: session.repMetrics.length,
      jointAngles: jointAngles,
      rangeScore: rangeScore,
      stabilityScore: stabilityScore,
      painFlag: painFlag,
    );
  }

  /// Extract joint angles from pose
  Map<String, dynamic> _extractJointAngles(Pose pose) {
    final angles = <String, double>{};

    // Calculate key angles
    angles['knee_left'] = _calculateKneeAngle(pose, 'left');
    angles['knee_right'] = _calculateKneeAngle(pose, 'right');
    angles['hip_left'] = _calculateHipAngle(pose, 'left');
    angles['hip_right'] = _calculateHipAngle(pose, 'right');
    angles['ankle_left'] = _calculateAnkleAngle(pose, 'left');
    angles['ankle_right'] = _calculateAnkleAngle(pose, 'right');
    angles['trunk_flexion'] = _calculateTrunkFlexion(pose);

    return angles;
  }

  /// Calculate knee angle
  double _calculateKneeAngle(Pose pose, String side) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip]!;
    final knee = pose.landmarks[PoseLandmarkType.leftKnee]!;
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle]!;

    // Calculate angle between hip-knee-ankle
    return _calculateAngle(hip, knee, ankle);
  }

  /// Calculate hip angle
  double _calculateHipAngle(Pose pose, String side) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final hip = pose.landmarks[PoseLandmarkType.leftHip]!;
    final knee = pose.landmarks[PoseLandmarkType.leftKnee]!;

    return _calculateAngle(shoulder, hip, knee);
  }

  /// Calculate ankle angle
  double _calculateAnkleAngle(Pose pose, String side) {
    final knee = pose.landmarks[PoseLandmarkType.leftKnee]!;
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle]!;
    final foot = pose.landmarks[PoseLandmarkType.leftFootIndex]!;

    return _calculateAngle(knee, ankle, foot);
  }

  /// Calculate trunk flexion
  double _calculateTrunkFlexion(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final hip = pose.landmarks[PoseLandmarkType.leftHip]!;

    // Calculate angle from vertical
    final dx = shoulder.x - hip.x;
    final dy = shoulder.y - hip.y;

    return atan2(dx, dy) * 180 / pi;
  }

  /// Calculate angle between three points
  double _calculateAngle(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
    final a = p1.x - p2.x;
    final b = p1.y - p2.y;
    final c = p3.x - p2.x;
    final d = p3.y - p2.y;

    final dot = a * c + b * d;
    final mag1 = sqrt(a * a + b * b);
    final mag2 = sqrt(c * c + d * d);

    final denom = mag1 * mag2;
    if (denom == 0 || denom.isNaN) return 0.0;
    final value = (dot / denom).clamp(-1.0, 1.0);
    // Protect against any NaN or rounding issues
    if (value.isNaN) return 0.0;
    return acos(value) * 180 / pi;
  }

  /// Calculate range of motion score
  double _calculateRangeScore(Map<String, dynamic> angles, String exerciseId) {
    // Exercise-specific ROM requirements
    final romRequirements = _getROMRequirements(exerciseId);

    double totalScore = 0.0;
    int validAngles = 0;

    for (final angle in romRequirements.entries) {
      final currentAngle = angles[angle.key] as double?;
      if (currentAngle != null) {
        final targetRange = angle.value;
        final score = _calculateRangeScoreForAngle(currentAngle, targetRange);
        totalScore += score;
        validAngles++;
      }
    }

    return validAngles > 0 ? totalScore / validAngles : 0.0;
  }

  /// Calculate stability score
  double _calculateStabilityScore(Map<String, dynamic> angles) {
    // Calculate variance in key stability angles
    final stabilityAngles = ['trunk_flexion', 'hip_left', 'hip_right'];
    double totalVariance = 0.0;

    for (final angle in stabilityAngles) {
      final value = angles[angle] as double?;
      if (value != null) {
        // Calculate variance (simplified)
        totalVariance += value.abs();
      }
    }

    // Convert variance to stability score (lower variance = higher stability)
    return (1.0 - (totalVariance / 1000.0)).clamp(0.0, 1.0);
  }

  /// Detect pain indicators
  bool _detectPainIndicators(Map<String, dynamic> angles) {
    // Look for compensation patterns that indicate pain
    final leftKnee = angles['knee_left'] as double? ?? 0;
    final rightKnee = angles['knee_right'] as double? ?? 0;
    final trunkFlexion = angles['trunk_flexion'] as double? ?? 0;

    // Asymmetry indicators
    final kneeAsymmetry = (leftKnee - rightKnee).abs();

    // Excessive compensation
    final excessiveTrunkFlexion = trunkFlexion.abs() > 30;

    return kneeAsymmetry > 15 || excessiveTrunkFlexion;
  }

  /// Get ROM requirements for exercise
  Map<String, List<double>> _getROMRequirements(String exerciseId) {
    switch (exerciseId) {
      case 'air_squat':
        return {
          'knee_left': [90, 120], // degrees
          'knee_right': [90, 120],
          'hip_left': [70, 100],
          'hip_right': [70, 100],
        };
      case 'push_up':
        return {
          'trunk_flexion': [-10, 10], // degrees from vertical
        };
      case 'plank':
        return {
          'trunk_flexion': [-5, 5],
        };
      default:
        return {};
    }
  }

  /// Calculate range score for specific angle
  double _calculateRangeScoreForAngle(double angle, List<double> targetRange) {
    final minTarget = targetRange[0];
    final maxTarget = targetRange[1];

    if (angle >= minTarget && angle <= maxTarget) {
      return 1.0; // Perfect range
    }

    // Calculate how far off the target range
    final distance = angle < minTarget ? minTarget - angle : angle - maxTarget;

    // Convert distance to score (farther = lower score)
    return (1.0 - (distance / 30.0)).clamp(0.0, 1.0);
  }

  /// Perform single movement test
  Future<MovementTestResult> _performSingleTest(
      String test, String userId) async {
    // Start AR session for the test
    final session = await startARSetSession(
      exerciseId: test,
      expectedReps: 5,
      tempo: '3-1-3-1',
      userId: userId,
    );

    // Wait for test completion
    await Future.delayed(const Duration(seconds: 30)); // Placeholder

    // Calculate test results
    final avgScore = session.repMetrics.isNotEmpty
        ? session.repMetrics.map((r) => r.repScore).reduce((a, b) => a + b) /
            session.repMetrics.length
        : 0.0;

    return MovementTestResult(
      test: test,
      score: avgScore,
      grade: _getGrade(avgScore),
      limitations: [], // TODO: Convert session.repMetrics to proper type
      recommendations: _getRecommendations(test, avgScore),
    );
  }

  /// Generate overall assessment
  Future<AssessmentResult> _generateAssessment(
      Map<String, MovementTestResult> results, String userId) async {
    final prompt = '''
    Analyze these movement assessment results and create a comprehensive report:
    
    Test Results: ${jsonEncode(results)}
    
    Generate:
    1. Overall movement quality grade (A-D)
    2. Key limitations and compensations
    3. Injury risk factors
    4. Recommended exercise modifications
    5. Mobility work priorities
    6. Strength training adjustments
    
    Return as JSON:
    {
      "overall_grade": "B",
      "limitations": ["ankle_mobility", "hip_flexibility"],
      "injury_risks": ["knee_valgus", "lower_back_strain"],
      "recommendations": {
        "mobility": ["ankle_dorsiflexion", "hip_flexor_stretch"],
        "strength_modifications": ["box_squat", "elevated_push_up"],
        "avoid_exercises": ["deep_squat", "overhead_squat"]
      },
      "progression_plan": {
        "phase_1": "mobility_focus",
        "phase_2": "movement_preparation", 
        "phase_3": "strength_building"
      }
    }
    ''';

    final response = await _aiService.chatCompletion(prompt);
    final assessmentJson = jsonDecode(response);

    return AssessmentResult.fromJson(assessmentJson);
  }

  /// Get grade from score
  String _getGrade(double score) {
    if (score >= 0.9) return 'A';
    if (score >= 0.8) return 'B';
    if (score >= 0.7) return 'C';
    return 'D';
  }

  /// Get recommendations based on test and score
  List<String> _getRecommendations(String test, double score) {
    if (score < 0.7) {
      switch (test) {
        case 'air_squat':
          return ['practice_box_squats', 'ankle_mobility_work'];
        case 'push_up':
          return ['elevated_push_ups', 'core_strengthening'];
        case 'plank':
          return ['modified_plank', 'core_stability_work'];
        default:
          return ['modify_exercise', 'focus_on_form'];
      }
    }
    return [];
  }

  /// Store rep metrics
  Future<void> _storeRepMetrics(rep_models.RepMetrics metrics) async {
    // Store in local database or send to server
    print('Storing rep metrics: ${metrics.toJson()}');
  }

  /// Provide real-time feedback
  Future<void> _provideRepFeedback(rep_models.RepMetrics metrics) async {
    String feedback = '';

    if (metrics.repScore >= 0.9) {
      feedback = 'Excellent form! 🎯';
    } else if (metrics.repScore >= 0.8) {
      feedback = 'Good form! Keep it up! 💪';
    } else if (metrics.repScore >= 0.7) {
      feedback = 'Focus on full range of motion 📏';
    } else if (metrics.painFlag) {
      feedback = 'Stop! Check for pain indicators ⚠️';
    } else {
      feedback = 'Slow down and focus on form 🎯';
    }

    // Send feedback to UI
    print('Rep feedback: $feedback');
  }
}

// Data Models

class ARSetSession {
  ARSetSession({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.expectedReps,
    required this.tempo,
    required this.startTime,
    required this.repMetrics,
    required this.isActive,
  });
  final String id;
  final String exerciseId;
  final String userId;
  final int expectedReps;
  final String tempo;
  final DateTime startTime;
  final List<rep_models.RepMetrics> repMetrics;
  bool isActive;
}

class MovementTestResult {
  MovementTestResult({
    required this.test,
    required this.score,
    required this.grade,
    required this.limitations,
    required this.recommendations,
  });
  final String test;
  final double score;
  final String grade;
  final List<String> limitations;
  final List<String> recommendations;

  Map<String, dynamic> toJson() {
    return {
      'test': test,
      'score': score,
      'grade': grade,
      'limitations': limitations,
      'recommendations': recommendations,
    };
  }
}

// Provider
final workoutAgentProvider = Provider<WorkoutAgent>((ref) {
  return WorkoutAgent(
    aiService: ref.read(aiServiceProvider),
    cameraService: ref.read(cameraServiceProvider),
  );
});

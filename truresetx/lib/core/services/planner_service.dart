import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/nutrition_plan.dart';
import '../../data/models/workout_plan.dart';
import 'ai_service.dart';

/// PlannerService: generates NutritionPlan and WorkoutPlan using AIService
class PlannerService {
  PlannerService({required this.ai});
  final AIService ai;

  /// Generate a nutrition plan by calling the AI and parsing the JSON result.
  Future<NutritionPlan?> generateNutritionPlan({
    required String userId,
    required Map<String, dynamic> profile,
    required List<String> goals,
    Map<String, dynamic>? prefs,
  }) async {
    final prompt = _buildNutritionPrompt(userId, profile, goals, prefs);
    final Map<String, dynamic>? json = await ai.chatCompletionJson(prompt);
    if (json == null) return null;

    try {
      // Merge in metadata and ensure plan_id and user_id exist
      if (!json.containsKey('plan_id')) {
        json['plan_id'] = 'plan-${DateTime.now().millisecondsSinceEpoch}';
      }
      json['user_id'] = userId;
      // Add metadata placeholder
      json['metadata'] = json['metadata'] ??
          {'generated_at': DateTime.now().toIso8601String()};
      return NutritionPlan.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      // Parsing failed
      print('PlannerService.generateNutritionPlan parse error: $e');
      return null;
    }
  }

  /// Generate a workout plan by calling the AI and parsing the JSON result.
  Future<WorkoutPlan?> generateWorkoutPlan({
    required String userId,
    required Map<String, dynamic> assessment,
    required Map<String, dynamic> profile,
    required int minutesPerSession,
  }) async {
    final prompt =
        _buildWorkoutPrompt(userId, assessment, profile, minutesPerSession);
    final Map<String, dynamic>? json = await ai.chatCompletionJson(prompt);
    if (json == null) return null;

    try {
      if (!json.containsKey('plan_id')) {
        json['plan_id'] = 'plan-${DateTime.now().millisecondsSinceEpoch}';
      }
      json['user_id'] = userId;
      json['metadata'] = json['metadata'] ??
          {'generated_at': DateTime.now().toIso8601String()};
      return WorkoutPlan.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      print('PlannerService.generateWorkoutPlan parse error: $e');
      return null;
    }
  }

  String _buildNutritionPrompt(String userId, Map<String, dynamic> profile,
      List<String> goals, Map<String, dynamic>? prefs) {
    final profileJson = jsonEncode(profile);
    final prefsJson = prefs != null ? jsonEncode(prefs) : '{}';
    return '''You are "Fuel", a nutritionist. Return ONLY valid JSON matching the NutritionPlan schema. Profile: $profileJson. Goals: ${jsonEncode(goals)}. Preferences: $prefsJson.''';
  }

  String _buildWorkoutPrompt(String userId, Map<String, dynamic> assessment,
      Map<String, dynamic> profile, int minutes) {
    final assessmentJson = jsonEncode(assessment);
    final profileJson = jsonEncode(profile);
    return '''You are "Astra", a strength coach. Return ONLY valid JSON matching the WorkoutPlan schema. Assessment: $assessmentJson. Profile: $profileJson. MinutesPerSession: $minutes.''';
  }
}

/// Provider
final plannerServiceProvider = Provider<PlannerService>((ref) {
  final ai = ref.read(aiServiceProvider);
  return PlannerService(ai: ai);
});

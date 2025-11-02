import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mental_health_assessment_service.dart';

/// Provider for MentalHealthAssessmentService
final mentalHealthAssessmentServiceProvider =
    Provider((ref) => MentalHealthAssessmentService());

/// FutureProvider for PHQ-9 questions
final phq9QuestionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(mentalHealthAssessmentServiceProvider);
  return service.getPHQ9Questions();
});

/// FutureProvider for GAD-7 questions
final gad7QuestionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(mentalHealthAssessmentServiceProvider);
  return service.getGAD7Questions();
});

/// StreamProvider for assessment history (real-time)
final assessmentHistoryStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  final service = ref.watch(mentalHealthAssessmentServiceProvider);
  return service.streamAssessmentHistory(
    type: params['type'] as String?,
    limit: params['limit'] as int? ?? 30,
  );
});

/// FutureProvider for assessment trends
final assessmentTrendsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(mentalHealthAssessmentServiceProvider);
  return service.getAssessmentTrends(
    type: params['type'] as String,
    days: params['days'] as int? ?? 30,
  );
});

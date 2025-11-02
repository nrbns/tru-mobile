import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meditation_service.dart';

/// Provider for MeditationService
final meditationServiceProvider = Provider((ref) => MeditationService());

/// StreamProvider for meditation library (real-time)
final meditationsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  final service = ref.watch(meditationServiceProvider);
  return service.streamMeditations(
    category: params['category'] as String?,
    difficulty: params['difficulty'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// FutureProvider for meditation library (non-stream version)
final meditationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getMeditations(
    category: params['category'] as String?,
    difficulty: params['difficulty'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// StreamProvider for meditation progress (real-time)
final meditationProgressStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(meditationServiceProvider);
  return service.streamMeditationProgress();
});

/// StreamProvider for today's meditations (real-time)
final todayMeditationsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(meditationServiceProvider);
  return service.streamTodayMeditations();
});

/// FutureProvider for meditation streak
final meditationStreakProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getMeditationStreak();
});

/// FutureProvider for weekly meditation summary
final weeklyMeditationSummaryProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getWeeklySummary();
});

/// FutureProvider for sleep stories
final sleepStoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getSleepStories();
});

/// StreamProvider for ambient sounds (real-time)
final ambientSoundsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(meditationServiceProvider);
  return service.streamAmbientSounds();
});

/// FutureProvider for meditation categories
final meditationCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getCategories();
});

import 'package:flutter/foundation.dart';
import '../data/recommendations_repository.dart';

/// AIOrchestrator stub: collects signals, calls detectors/twins (in real system it calls AI models/Edge Functions)
class AIOrchestrator {
  AIOrchestrator();

  final _recRepo = RecommendationsRepository.instance;

  /// Accepts detected events and creates simple recommendations.
  Future<void> handleDetectedEvents(String userId, List<String> events) async {
    for (final e in events) {
      if (e == 'love_failure') {
        await _recRepo.addRecommendation(userId, 'Heartbreak Starter',
            'Try a 3-minute grounding and a short journaling prompt.');
      } else if (e == 'financial_shock') {
        await _recRepo.addRecommendation(userId, 'Financial Calm',
            'List 3 immediate steps you can take; schedule one micro-action.');
      } else if (e == 'sustained_low_mood') {
        await _recRepo.addRecommendation(userId, 'Mood Check',
            'Short mood check-in and a 2-min breath reset.');
      } else if (e == 'sleep_deprivation') {
        await _recRepo.addRecommendation(userId, 'Sleep Wind-down',
            'Try a 20-min wind-down + no screens protocol.');
      }
    }
    if (kDebugMode) {
      debugPrint('AIOrchestrator created ${events.length} recs for $userId');
    }
  }
}

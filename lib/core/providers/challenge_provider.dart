import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/challenge_service.dart';

final challengeServiceProvider = Provider((ref) => ChallengeService());

final availableChallengesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  return ref.watch(challengeServiceProvider).streamChallenges(
        category: params['category'] as String?,
        limit: params['limit'] as int? ?? 20,
      );
});

final userChallengesProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(challengeServiceProvider).streamUserChallenges();
});

final challengeLeaderboardStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, challengeId) {
  return ref
      .watch(challengeServiceProvider)
      .streamChallengeLeaderboard(challengeId);
});

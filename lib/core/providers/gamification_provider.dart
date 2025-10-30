import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gamification_service.dart';

final gamificationServiceProvider = Provider((ref) => GamificationService());

final userAchievementsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(gamificationServiceProvider).streamUserAchievements();
});

final achievementStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(gamificationServiceProvider).getAchievementStats();
});

final userLevelProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(gamificationServiceProvider).getUserLevel();
});

final allStreaksProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(gamificationServiceProvider).getAllStreaks();
});


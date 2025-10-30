import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Gamification Service - Badges, achievements, streaks, leaderboards
class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('GamificationService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _userAchievementsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('achievements');
  }

  CollectionReference get _badgesRef => _firestore.collection('badges');

  /// Unlock an achievement
  Future<void> unlockAchievement({
    required String achievementId,
    String? category, // body, mind, spirit, milestone
    Map<String, dynamic>? metadata,
  }) async {
    await _userAchievementsRef.doc(achievementId).set({
      'unlocked_at': FieldValue.serverTimestamp(),
      'category': category,
      'metadata': metadata ?? {},
    }, SetOptions(merge: true));
  }

  /// Check and unlock achievements based on user stats
  Future<void> checkAchievements({
    int? streak,
    int? totalWorkouts,
    int? totalMoods,
    int? spiritualStreak,
    int? totalReflections,
    int? challengeCompletions,
  }) async {
    // Streak achievements
    if (streak != null) {
      if (streak >= 7 && streak < 14) {
        await unlockAchievement(
            achievementId: 'streak_7', category: 'milestone');
      } else if (streak >= 30) {
        await unlockAchievement(
            achievementId: 'streak_30', category: 'milestone');
      } else if (streak >= 100) {
        await unlockAchievement(
            achievementId: 'streak_100', category: 'milestone');
      }
    }

    // Workout achievements
    if (totalWorkouts != null) {
      if (totalWorkouts >= 10) {
        await unlockAchievement(achievementId: 'workout_10', category: 'body');
      } else if (totalWorkouts >= 50) {
        await unlockAchievement(achievementId: 'workout_50', category: 'body');
      } else if (totalWorkouts >= 100) {
        await unlockAchievement(achievementId: 'workout_100', category: 'body');
      }
    }

    // Mood tracking achievements
    if (totalMoods != null) {
      if (totalMoods >= 30) {
        await unlockAchievement(
            achievementId: 'mood_tracker_30', category: 'mind');
      } else if (totalMoods >= 100) {
        await unlockAchievement(
            achievementId: 'mood_tracker_100', category: 'mind');
      }
    }

    // Spiritual achievements
    if (spiritualStreak != null) {
      if (spiritualStreak >= 7) {
        await unlockAchievement(
            achievementId: 'spiritual_streak_7', category: 'spirit');
      } else if (spiritualStreak >= 30) {
        await unlockAchievement(
            achievementId: 'spiritual_streak_30', category: 'spirit');
      }
    }

    // Reflection achievements
    if (totalReflections != null && totalReflections >= 10) {
      await unlockAchievement(
          achievementId: 'wisdom_reflector', category: 'spirit');
    }

    // Challenge completions
    if (challengeCompletions != null && challengeCompletions >= 1) {
      await unlockAchievement(
          achievementId: 'challenge_completer', category: 'milestone');
    }
  }

  /// Get user's achievements
  Stream<List<Map<String, dynamic>>> streamUserAchievements() {
    return _userAchievementsRef.snapshots().asyncMap((snapshot) async {
      final achievements = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final achievementData = doc.data() as Map<String, dynamic>? ?? {};

        // Get badge details if available
        final badgeDoc = await _badgesRef.doc(doc.id).get();
        if (badgeDoc.exists) {
          final badgeData = badgeDoc.data() as Map<String, dynamic>? ?? {};
          achievements.add({
            'id': doc.id,
            ...badgeData,
            'unlocked_at': achievementData['unlocked_at'],
            'category': achievementData['category'],
            'metadata': achievementData['metadata'] ?? {},
          });
        } else {
          achievements.add({
            'id': doc.id,
            'name': doc.id
                .replaceAll('_', ' ')
                .split(' ')
                .map(
                    (w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
                .join(' '),
            'description': 'Achievement unlocked',
            'unlocked_at': achievementData['unlocked_at'],
            'category': achievementData['category'],
          });
        }
      }

      return achievements;
    });
  }

  /// Get available badges
  Future<List<Map<String, dynamic>>> getAvailableBadges(
      {String? category}) async {
    Query query = _badgesRef.limit(100);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Get achievement stats
  Future<Map<String, dynamic>> getAchievementStats() async {
    final achievementsSnapshot = await _userAchievementsRef.get();
    final totalAchievements = achievementsSnapshot.docs.length;

    // Count by category
    final categoryCounts = <String, int>{};
    for (var doc in achievementsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category'] as String? ?? 'unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return {
      'total_achievements': totalAchievements,
      'by_category': categoryCounts,
      'latest_achievement': achievementsSnapshot.docs.isNotEmpty
          ? () {
              final latest = achievementsSnapshot.docs.first;
              final latestData = latest.data() as Map<String, dynamic>? ?? {};
              return {
                'id': latest.id,
                'unlocked_at': latestData['unlocked_at'],
              };
            }()
          : null,
    };
  }

  /// Get streak information
  Future<Map<String, int>> getAllStreaks() async {
    final uid = _requireUid();

    // Get today data
    final todayDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .doc(DateTime.now().toIso8601String().split('T')[0])
        .get();

    final todayData = todayDoc.data() ?? <String, dynamic>{};

    return {
      'general_streak': todayData['streak'] as int? ?? 0,
      'workout_streak': await _calculateStreak('workout_logs'),
      'mood_streak': await _calculateStreak('mood_logs'),
      'spiritual_streak': await _calculateStreak('practice_logs'),
      'nutrition_streak': await _calculateStreak('meal_logs'),
    };
  }

  Future<int> _calculateStreak(String collectionName) async {
    final uid = _requireUid();
    final today = DateTime.now();
    int streak = 0;
    DateTime currentDate = today;

    for (int i = 0; i < 365; i++) {
      final dateKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(collectionName)
          .where('date', isEqualTo: dateKey)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break;
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get user level/XP (calculated from achievements and activity)
  Future<Map<String, dynamic>> getUserLevel() async {
    final stats = await getAchievementStats();
    final streaks = await getAllStreaks();

    // Simple XP calculation
    final baseXP = stats['total_achievements'] as int? ?? 0;
    final streakXP = streaks.values.reduce((a, b) => a + b) * 10;
    final totalXP = baseXP * 100 + streakXP;

    // Level calculation (every 1000 XP = 1 level)
    final level = (totalXP / 1000).floor() + 1;
    final xpToNextLevel = 1000 - (totalXP % 1000);

    return {
      'level': level,
      'total_xp': totalXP,
      'current_xp': totalXP % 1000,
      'xp_to_next_level': xpToNextLevel,
      'streaks': streaks,
      'achievements_count': stats['total_achievements'],
    };
  }
}

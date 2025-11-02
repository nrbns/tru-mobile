import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/progress_ring.dart';
import '../../core/providers/spiritual_provider.dart';

class StreaksDetailScreen extends ConsumerWidget {
  const StreaksDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceLogsAsync = ref.watch(practiceLogsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streaks Detail',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Track your progress',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: practiceLogsAsync.when(
                data: (logs) {
                  final streaks = _calculateStreaks(logs);
                  final currentStreak = streaks['current'] as int;
                  final streakPercent = (currentStreak / 30.0 * 100).clamp(0.0, 100.0);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Overall Streak
                        AuraCard(
                          variant: AuraCardVariant.spiritual,
                          glow: true,
                          child: Row(
                            children: [
                              ProgressRing(
                                progress: streakPercent,
                                size: 100,
                                strokeWidth: 8,
                                color: AppColors.spiritualColor,
                                showPercentage: true,
                                glow: true,
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Streak',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$currentStreak ${currentStreak == 1 ? 'Day' : 'Days'}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.flame,
                                          color: AppColors.spiritualColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          currentStreak > 7 ? 'Amazing!' : currentStreak > 3 ? 'Keep going!' : 'Start your streak!',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Individual Streaks
                        const Text(
                          'Your Streaks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...(streaks['practiceStreaks'] as Map<String, Map<String, int>>).entries.map((entry) {
                          return _StreakItem(
                            icon: _getIconForPractice(entry.key),
                            title: entry.key,
                            days: entry.value['current'] ?? 0,
                            best: entry.value['best'] ?? 0,
                          );
                        }),
                        if ((streaks['practiceStreaks'] as Map<String, Map<String, int>>).isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(LucideIcons.flame, size: 64, color: Colors.grey[600]),
                                const SizedBox(height: 16),
                                Text(
                                  'No streaks yet',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Complete your first practice to start a streak!',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error loading streaks', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStreaks(List<Map<String, dynamic>> logs) {
    final now = DateTime.now();
    final practiceDays = <String, Set<String>>{};
    final practiceStreaks = <String, Map<String, int>>{};

    // Group logs by practice and date
    for (final log in logs) {
      final atField = log['at'];
      if (atField == null || atField is! Timestamp) continue;
      
      final logDate = atField.toDate();
      final dateKey = '${logDate.year}-${logDate.month}-${logDate.day}';
      final practiceId = log['practice_id'] as String? ?? 'Unknown Practice';
      
      practiceDays.putIfAbsent(practiceId, () => <String>{}).add(dateKey);
    }

    // Calculate streaks for each practice
    int overallCurrent = 0;
    int overallBest = 0;

    for (final entry in practiceDays.entries) {
      final dates = entry.value.map((d) {
        final parts = d.split('-');
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }).toList()..sort();

      int current = 0;
      int best = 0;
      int temp = 1;

      // Calculate current streak (from today backwards)
      DateTime checkDate = DateTime(now.year, now.month, now.day);
      final dateSet = dates.toSet();
      while (dateSet.any((d) => d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day)) {
        current++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Calculate best streak
      for (int i = 1; i < dates.length; i++) {
        final diff = dates[i].difference(dates[i - 1]).inDays;
        if (diff == 1) {
          temp++;
        } else {
          best = best > temp ? best : temp;
          temp = 1;
        }
      }
      best = best > temp ? best : temp;

      practiceStreaks[entry.key] = {'current': current, 'best': best};
      overallCurrent = overallCurrent > current ? overallCurrent : current;
      overallBest = overallBest > best ? overallBest : best;
    }

    return {
      'current': overallCurrent,
      'best': overallBest,
      'practiceStreaks': practiceStreaks,
    };
  }

  IconData _getIconForPractice(String practice) {
    final lower = practice.toLowerCase();
    if (lower.contains('prayer') || lower.contains('heart')) return LucideIcons.heart;
    if (lower.contains('scripture') || lower.contains('book') || lower.contains('reading')) return LucideIcons.bookOpen;
    if (lower.contains('meditation') || lower.contains('mindful')) return LucideIcons.sparkles;
    if (lower.contains('reflection') || lower.contains('evening')) return LucideIcons.moon;
    return LucideIcons.calendar;
  }
}

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int days;
  final int best;

  const _StreakItem({
    required this.icon,
    required this.title,
    required this.days,
    required this.best,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.spiritualColor.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.spiritualColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.flame,
                        size: 14,
                        color: AppColors.spiritualColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$days days',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        LucideIcons.trophy,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Best: $best days',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

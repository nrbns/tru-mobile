import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/mood_provider.dart';

class MoodTimelineScreen extends ConsumerWidget {
  const MoodTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodLogsAsync = ref.watch(moodLogsStreamProvider);
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
                          'Mood Timeline',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'View your mood history',
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
              child: moodLogsAsync.when(
                data: (moodLogs) {
                  if (moodLogs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No mood logs yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Mood Chart
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AuraCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mood Trend (Last 7 Days)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: moodLogs
                                            .take(7)
                                            .toList()
                                            .asMap()
                                            .entries
                                            .map((e) {
                                          final log = e.value;
                                          return FlSpot(
                                            e.key.toDouble(),
                                            (log.score / 10.0).clamp(0.0, 1.0),
                                          );
                                        }).toList(),
                                        isCurved: true,
                                        color: AppColors.moodColor,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppColors.moodColor
                                              .withAlpha((0.1 * 255).round()),
                                        ),
                                      ),
                                    ],
                                    minY: 0,
                                    maxY: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Mood Logs List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: moodLogs.length,
                          itemBuilder: (context, index) {
                            final log = moodLogs[index];
                            final moodScore = log.score;

                            Color moodColor;
                            String moodLabel;
                            if (moodScore >= 8) {
                              moodColor = AppColors.success;
                              moodLabel = 'Excellent';
                            } else if (moodScore >= 6) {
                              moodColor = AppColors.primary;
                              moodLabel = 'Good';
                            } else if (moodScore >= 4) {
                              moodColor = AppColors.warning;
                              moodLabel = 'Okay';
                            } else {
                              moodColor = AppColors.error;
                              moodLabel = 'Low';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AuraCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: moodColor
                                            .withAlpha((0.2 * 255).round()),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        LucideIcons.heart,
                                        color: moodColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${log.score}/10 - $moodLabel',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (log.note != null &&
                                              log.note!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              log.note!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[400],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          if (log.emotions.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 4,
                                              children: log.emotions
                                                  .take(3)
                                                  .map((emotion) => Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: moodColor
                                                              .withAlpha(
                                                                  (0.2 * 255)
                                                                      .round()),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                          emotion,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: moodColor,
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(log.at),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading moods: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

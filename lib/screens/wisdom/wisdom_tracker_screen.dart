import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/wisdom_provider.dart';

class WisdomTrackerScreen extends ConsumerWidget {
  const WisdomTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(wisdomStreakProvider);
    final reflectionsAsync = ref.watch(wisdomReflectionsStreamProvider);
    final savedWisdomAsync = ref.watch(savedWisdomStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha((0.8 * 255).round()),
                border: const Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
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
                          'Wisdom Tracker',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Your wisdom journey',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Streak Card
                    streakAsync.when(
                      data: (streak) => AuraCard(
                        glow: streak > 0,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.flame,
                                  color:
                                      streak > 0 ? Colors.orange : Colors.grey,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$streak',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: streak > 0
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              streak > 0
                                  ? 'Day Wisdom Streak!'
                                  : 'Start your wisdom journey',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(LucideIcons.bookOpen,
                                          color: AppColors.primary, size: 24),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${reflectionsAsync.valueOrNull?.length ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Reflections',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(LucideIcons.bookmark,
                                          color: AppColors.secondary, size: 24),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${savedWisdomAsync.valueOrNull?.length ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Saved',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
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
                      loading: () => const AuraCard(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => AuraCard(
                        child: Text('Error: $err',
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recent Reflections
                    reflectionsAsync.when(
                      data: (reflections) {
                        if (reflections.isEmpty) {
                          return AuraCard(
                            child: Column(
                              children: [
                                Icon(LucideIcons.bookOpen,
                                    color: Colors.grey[600], size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No reflections yet',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.push('/spirit/wisdom-daily'),
                                  icon: const Icon(LucideIcons.bookOpen),
                                  label: const Text('Start Reflecting'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Reflections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...reflections.take(5).map((reflection) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AuraCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.lightbulb,
                                            color: AppColors.secondary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Reflected ${_formatDate(_dateFromDynamic(reflection['createdAt']))}',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if ((reflection['reflection']
                                              as String?) !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          reflection['reflection'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (reflection['moodBefore'] != null ||
                                          reflection['moodAfter'] != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (reflection['moodBefore'] !=
                                                null) ...[
                                              Text(
                                                'Mood: ${reflection['moodBefore']}',
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                            if (reflection['moodAfter'] !=
                                                null) ...[
                                              if (reflection['moodBefore'] !=
                                                  null) ...[
                                                Text(' → ',
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 11)),
                                              ],
                                              Text(
                                                '${reflection['moodAfter']}',
                                                style: const TextStyle(
                                                  color: AppColors.success,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err',
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  DateTime? _dateFromDynamic(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final parsed = int.tryParse(v);
      if (parsed != null) return DateTime.fromMillisecondsSinceEpoch(parsed);
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    if (v is Map && v['seconds'] != null) {
      final seconds = v['seconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    return null;
  }
}

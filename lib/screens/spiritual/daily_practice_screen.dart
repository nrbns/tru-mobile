import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_provider.dart';
import '../../widgets/progress_ring.dart';

class DailyPracticeScreen extends ConsumerStatefulWidget {
  const DailyPracticeScreen({super.key});

  @override
  ConsumerState<DailyPracticeScreen> createState() =>
      _DailyPracticeScreenState();
}

class _DailyPracticeScreenState extends ConsumerState<DailyPracticeScreen> {
  @override
  Widget build(BuildContext context) {
    final practicesAsync = ref.watch(practicesStreamProvider({
      'limit': 10,
    }));

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
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Practice',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Your spiritual routine',
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
                  const SizedBox(height: 16),
                  // Progress Overview
                  practicesAsync.when(
                    data: (practices) {
                      // Get today's practice logs to calculate progress
                      final practiceLogsAsync =
                          ref.watch(practiceLogsStreamProvider);
                      return practiceLogsAsync.when(
                        data: (logs) {
                          final today = DateTime.now();
                          final todayLogs = logs.where((log) {
                            final logDate = (log['at'] as Timestamp).toDate();
                            return logDate.year == today.year &&
                                logDate.month == today.month &&
                                logDate.day == today.day;
                          }).toList();

                          final completedIds = todayLogs
                              .map((log) => log['practice_id'] as String)
                              .toSet();
                          final completed = practices
                              .where((p) => completedIds.contains(p['id']))
                              .length;
                          final progress = practices.isEmpty
                              ? 0.0
                              : (completed / practices.length) * 100;

                          return AuraCard(
                            variant: AuraCardVariant.spiritual,
                            child: Row(
                              children: [
                                ProgressRing(
                                  progress: progress,
                                  size: 80,
                                  strokeWidth: 8,
                                  color: AppColors.secondary,
                                  showPercentage: false,
                                  glow: true,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$completed of ${practices.length} Complete',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Keep up the great work! 🙏',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox(height: 60),
                        error: (_, __) => const SizedBox(height: 60),
                      );
                    },
                    loading: () => const SizedBox(height: 60),
                    error: (_, __) => const SizedBox(height: 60),
                  ),
                ],
              ),
            ),
            // Practice List
            Expanded(
              child: practicesAsync.when(
                data: (practices) {
                  if (practices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.sparkles,
                              size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'No practices found',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add practices to Firestore collection',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  final practiceLogsAsync =
                      ref.watch(practiceLogsStreamProvider);
                  return practiceLogsAsync.when(
                    data: (logs) {
                      final today = DateTime.now();
                      final todayLogs = logs.where((log) {
                        final atField = log['at'];
                        if (atField == null) return false;
                        DateTime logDate;
                        if (atField is Timestamp) {
                          logDate = atField.toDate();
                        } else if (atField is Map) {
                          return false; // Server timestamp placeholder
                        } else {
                          return false;
                        }
                        return logDate.year == today.year &&
                            logDate.month == today.month &&
                            logDate.day == today.day;
                      }).toList();

                      final completedIds = todayLogs
                          .map((log) => log['practice_id'] as String)
                          .toSet();

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: practices.length,
                        itemBuilder: (context, index) {
                          final practice = practices[index];
                          final isCompleted =
                              completedIds.contains(practice['id']);

                          return _PracticeCard(
                            practice: practice,
                            isCompleted: isCompleted,
                            onToggle: () async {
                              final service =
                                  ref.read(spiritualServiceProvider);
                              if (isCompleted) {
                                // Could implement un-complete if needed
                              } else {
                                await service.logPractice(
                                  practiceId: practice['id'] as String,
                                  durationMin:
                                      practice['duration_min'] as int? ?? 15,
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: $error',
                          style: const TextStyle(color: Colors.red)),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading practices',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(practicesStreamProvider({'limit': 10})),
                        child: const Text('Retry'),
                      ),
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
}

class _PracticeCard extends StatelessWidget {
  final Map<String, dynamic> practice;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _PracticeCard({
    required this.practice,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch ((practice['name'] as String? ?? '').toLowerCase()) {
      case 'morning prayer':
      case 'prayer':
        icon = LucideIcons.heart;
        break;
      case 'scripture':
      case 'scripture reading':
        icon = LucideIcons.bookOpen;
        break;
      case 'meditation':
        icon = LucideIcons.sparkles;
        break;
      default:
        icon = LucideIcons.moon;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        variant:
            isCompleted ? AuraCardVariant.spiritual : AuraCardVariant.default_,
        glow: isCompleted,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.spiritualColor.withAlpha((0.2 * 255).round())
                    : AppColors.textMuted.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isCompleted
                    ? AppColors.spiritualColor
                    : AppColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    practice['name'] as String? ?? 'Practice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${practice['duration_min'] ?? 15} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (practice['difficulty'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary
                                .withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            practice['difficulty'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isCompleted ? LucideIcons.checkCircle : LucideIcons.circle,
                color: isCompleted
                    ? AppColors.spiritualColor
                    : AppColors.textMuted,
                size: 24,
              ),
              onPressed: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

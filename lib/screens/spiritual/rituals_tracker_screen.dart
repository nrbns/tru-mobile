import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_provider.dart';

class RitualsTrackerScreen extends ConsumerStatefulWidget {
  const RitualsTrackerScreen({super.key});

  @override
  ConsumerState<RitualsTrackerScreen> createState() =>
      _RitualsTrackerScreenState();
}

class _RitualsTrackerScreenState extends ConsumerState<RitualsTrackerScreen> {
  @override
  Widget build(BuildContext context) {
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
                          'Rituals Tracker',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Track your spiritual rituals',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(LucideIcons.plus, color: AppColors.primary),
                    onPressed: () {
                      // Show dialog to add new ritual
                      _showAddRitualDialog(context);
                    },
                  ),
                ],
              ),
            ),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: AuraCard(
                      child: Column(
                        children: [
                          Text(
                            practiceLogsAsync.when(
                              data: (logs) => logs.length.toString(),
                              loading: () => '0',
                              error: (_, __) => '0',
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total Logs',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuraCard(
                      child: Column(
                        children: [
                          Text(
                            practiceLogsAsync.when(
                              data: (logs) {
                                final thisWeek = logs.where((log) {
                                  final atField = log['at'];
                                  if (atField == null) return false;
                                  if (atField is! Timestamp) return false;
                                  final logDate = atField.toDate();
                                  final now = DateTime.now();
                                  final weekStart = now.subtract(
                                      Duration(days: now.weekday - 1));
                                  return logDate.isAfter(weekStart);
                                }).length;
                                return thisWeek.toString();
                              },
                              loading: () => '0',
                              error: (_, __) => '0',
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'This Week',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Recent Logs
            Expanded(
              child: practiceLogsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.calendar,
                              size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'No rituals logged yet',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddRitualDialog(context),
                            child: const Text('Add Ritual'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _RitualLogCard(log: log);
                    },
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
                        'Error loading rituals',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(practiceLogsStreamProvider),
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

  void _showAddRitualDialog(BuildContext context) {
    // This would show a dialog to add a new ritual
    // For now, just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Ritual', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Ritual logging feature coming soon',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _RitualLogCard extends StatelessWidget {
  final Map<String, dynamic> log;

  const _RitualLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final atField = log['at'];
    DateTime? logDate;
    if (atField != null && atField is Timestamp) {
      logDate = atField.toDate();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        variant: AuraCardVariant.spiritual,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.spiritualColor.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.calendar,
                color: AppColors.spiritualColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice: ${log['practice_id'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.clock,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        logDate != null
                            ? '${logDate.day}/${logDate.month}/${logDate.year}'
                            : 'Date unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (log['duration_min'] != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${log['duration_min']} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

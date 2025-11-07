import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/current_user_provider.dart';
import '../../core/data/metrics_repository.dart';
import '../../core/widgets/skeleton_loader.dart';

class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sign in to see today\'s metrics',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/auth'),
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final async = ref.watch(metricsStreamProvider(userId));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: async.when(
          data: (list) {
            final latest = list.isNotEmpty ? list.first : null;
            final kg = latest?['kg'];

            // Calculate average weight
            double avg = 0;
            var count = 0;
            for (var r in list) {
              final v = r['kg'];
              if (v is num) {
                avg += v.toDouble();
                count++;
              }
            }
            final avgStr = count > 0 ? (avg / count).toStringAsFixed(1) : '--';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGreeting(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Metrics Grid
                _MetricsGrid(
                  weight: kg?.toStringAsFixed(1) ?? '--',
                  avgWeight: avgStr,
                  weightCount: list.length,
                ),
              ],
            );
          },
          loading: () =>
              const SkeletonLoader(height: 200.0, borderRadius: 20.0),
          error: (e, st) => _ErrorState(error: e.toString()),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}

class _MetricsGrid extends StatelessWidget {
  final String weight;
  final String avgWeight;
  final int weightCount;

  const _MetricsGrid({
    required this.weight,
    required this.avgWeight,
    required this.weightCount,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder data - in real app, these would come from providers
    final metrics = [
      _MetricItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Weight',
        value: '$weight kg',
        subtitle: 'Avg: $avgWeight kg',
        color: Colors.blue,
        onTap: () => context.push('/metrics/weight'),
      ),
      _MetricItem(
        icon: Icons.restaurant_outlined,
        label: 'Calories',
        value: '--',
        subtitle: 'Target: 2000',
        color: Colors.green,
        onTap: () => context.push('/nutrition/food'),
      ),
      _MetricItem(
        icon: Icons.fitness_center_outlined,
        label: 'Protein',
        value: '-- g',
        subtitle: 'Target: 150g',
        color: Colors.orange,
        onTap: () => context.push('/nutrition/food'),
      ),
      _MetricItem(
        icon: Icons.timer_outlined,
        label: 'Workout',
        value: '-- min',
        subtitle: 'Today',
        color: Colors.red,
        onTap: () => context.push('/workout/start'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _MetricCard(metric: metric);
      },
    );
  }
}

class _MetricItem {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItem metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: metric.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: metric.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: metric.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  metric.icon,
                  color: metric.color,
                  size: 24,
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: metric.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'Error loading metrics',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          error,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A small quick-tile placed on Today that deep-links to Life OS overview.
class LifeOSTile extends ConsumerWidget {
  const LifeOSTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: InkWell(
        onTap: () => context.go('/life-os'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.eco_outlined,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life OS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resilience & events',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

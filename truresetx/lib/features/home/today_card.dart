import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:truresetx/core/services/current_user_provider.dart';
import 'package:truresetx/core/data/metrics_repository.dart';
import 'package:truresetx/core/widgets/skeleton_loader.dart';

class TodayCard extends ConsumerWidget {
  const TodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 12),
              const Expanded(child: Text('Sign in to see today\'s metrics')),
              ElevatedButton(onPressed: () {}, child: const Text('Sign in')),
            ],
          ),
        ),
      );
    }

    final async = ref.watch(metricsStreamProvider(userId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: async.when(
          data: (list) {
            if (list.isEmpty) {
              return Row(
                children: const [
                  Icon(Icons.monitor_weight_outlined),
                  SizedBox(width: 12),
                  Expanded(
                      child:
                          Text('No weight logs yet — add your first weight')),
                ],
              );
            }

            final latest = list.first;
            final kg = latest['kg'] ?? '--';
            // compute simple avg over available rows
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
                Row(
                  children: [
                    const Icon(Icons.monitor_weight_outlined, size: 32),
                    const SizedBox(width: 12),
                    Text('Today',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text('$kg kg',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Avg: $avgStr kg • ${list.length} samples',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            );
          },
          loading: () => const SkeletonLoader(height: 64.0, borderRadius: 12.0),
          error: (e, st) => Text('Error: $e'),
        ),
      ),
    );
  }
}

/// A small quick-tile placed on Today that deep-links to Life OS overview.
class LifeOSTile extends ConsumerWidget {
  const LifeOSTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: InkWell(
        onTap: () => context.go('/life-os'),
        borderRadius: BorderRadius.circular(12),
        child: Semantics(
          button: true,
          label: 'Open Life OS overview',
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              // Use withAlpha to avoid the deprecated withOpacity API
              color: Theme.of(context).colorScheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Life OS — Resilience & events',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

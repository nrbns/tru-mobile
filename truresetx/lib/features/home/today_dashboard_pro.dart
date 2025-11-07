import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/widgets/skeleton_loader.dart';
import '../../core/services/current_user_provider.dart';
import '../../core/data/recommendations_repository.dart';
import '../../core/data/wellness_repository.dart';

/// TodayDashboardPro: Hero stat chips, actions, Life OS tile, recommendations stream.
class TodayDashboardPro extends ConsumerWidget {
  const TodayDashboardPro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruResetX'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Updated timestamp + Live indicator
            Row(
              children: [
                Text('Updated just now', style: theme.textTheme.labelSmall),
                const SizedBox(width: 8),
                _LiveBadge(isLive: true),
              ],
            ),
            const SizedBox(height: 12),

            // Hero stat chips
            _HeroStatRow(),
            const SizedBox(height: 16),

            // Actions row
            _ActionsRow(),
            const SizedBox(height: 16),

            // Life OS tile
            GestureDetector(
              onTap: () => context.go('/life-os'),
              child: Container(
                height: 92,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary
                  ]),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_alt_outlined,
                        size: 36, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Life OS — Adaptive reset',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Realtime insights • Resilience-focused',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recommendations header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recommendations', style: theme.textTheme.titleMedium),
                TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/recommendations'),
                    child: const Text('See all'))
              ],
            ),

            // Recommendations stream (placeholder skeleton -> list)
            const SizedBox(height: 8),
            _RecommendationsList(),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isLive});
  final bool isLive;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isLive ? Colors.redAccent : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        if (isLive)
          const Text('Live',
              style: TextStyle(fontSize: 12, color: Colors.redAccent))
      ],
    );
  }
}

class _HeroStatRow extends ConsumerWidget {
  const _HeroStatRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _StatChip(label: 'Resilience', value: '--'),
          _StatChip(label: 'Mood', value: '--'),
          _StatChip(label: 'Sleep', value: '--'),
          _StatChip(label: 'Activity', value: '--'),
        ],
      );
    }

    final liveAsync = ref.watch(liveMetricsStreamProvider(userId));
    return liveAsync.when(
      data: (map) {
        final resilience =
            (map['mentalScore'] as num?)?.toStringAsFixed(0) ?? '—';
        final mood = (map['mood'] as num?)?.toStringAsFixed(1) ?? '—';
        final sleep = (map['sleepHours'] as num?) != null
            ? '${(map['sleepHours'] as num).toStringAsFixed(1)}h'
            : '—';
        final activity = (map['activityMin'] as num?) != null
            ? '${map['activityMin'] as int}m'
            : '—';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatChip(label: 'Resilience', value: resilience),
            _StatChip(label: 'Mood', value: mood),
            _StatChip(label: 'Sleep', value: sleep),
            _StatChip(label: 'Activity', value: activity),
          ],
        );
      },
      loading: () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _StatChip(label: 'Resilience', value: '--'),
          _StatChip(label: 'Mood', value: '--'),
          _StatChip(label: 'Sleep', value: '--'),
          _StatChip(label: 'Activity', value: '--'),
        ],
      ),
      error: (e, st) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _StatChip(label: 'Resilience', value: '--'),
          _StatChip(label: 'Mood', value: '--'),
          _StatChip(label: 'Sleep', value: '--'),
          _StatChip(label: 'Activity', value: '--'),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActionsRow extends ConsumerWidget {
  const _ActionsRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    // Present actions as an icon grid so the main functions are reachable from a single screen
    return Row(
      children: [
        Expanded(
          child: _IconTile(
            label: 'Mood',
            icon: Icons.mood,
            enabled: userId != null,
            onTap: userId == null ? null : () => _showLogMood(context, userId),
          ),
        ),
        Expanded(
          child: _IconTile(
            label: 'Workout',
            icon: Icons.fitness_center,
            enabled: true,
            onTap: () => Navigator.of(context).pushNamed('/workout/start'),
          ),
        ),
        Expanded(
          child: _IconTile(
            label: 'Meditate',
            icon: Icons.self_improvement,
            enabled: true,
            onTap: () => Navigator.of(context).pushNamed('/meditate'),
          ),
        ),
        Expanded(
          child: _IconTile(
            label: 'Meals',
            icon: Icons.restaurant,
            enabled: true,
            onTap: () => Navigator.of(context).pushNamed('/meals'),
          ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile(
      {required this.label,
      required this.icon,
      this.onTap,
      this.enabled = true});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withAlpha((0.12 * 255).round()),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsList extends ConsumerWidget {
  const _RecommendationsList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return const Center(child: Text('Sign in to see recommendations'));
    }

    final stream =
        RecommendationsRepository.instance.streamRecommendations(userId);
    return StreamBuilder<List<Recommendation>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Column(
            children: const [
              SkeletonLoader(height: 72.0, borderRadius: 12.0),
              SkeletonLoader(height: 72.0, borderRadius: 12.0),
            ],
          );
        }
        if (snap.hasError) {
          return const ErrorCard(message: 'Failed to load recommendations');
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(
              child: Text(
                  'No recommendations yet — we will notify you when new items arrive.'));
        }
        return Column(
          children: items.map((r) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.lightbulb_outline)),
              title: Text(r.title),
              subtitle: Text(r.body),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => Navigator.of(context)
                  .pushNamed('/recommendation', arguments: r.id),
            );
          }).toList(),
        );
      },
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, this.message = 'Something went wrong'});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retry'))
        ],
      ),
    );
  }
}

// Simple modal to log mood value and write into Firestore under users/{uid}/entries
Future<void> _showLogMood(BuildContext context, String userId) async {
  double value = 6.0;
  final res = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Log Mood'),
      content: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How are you feeling? ${value.toStringAsFixed(1)}'),
            Slider(
              min: 0,
              max: 10,
              divisions: 20,
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ],
        );
      }),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save')),
      ],
    ),
  );

  if (res == true) {
    try {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('entries')
          .doc();
      await doc.set({
        'type': 'mood',
        'value': value,
        'recordedAt': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Mood saved')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to save mood')));
      }
    }
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Today'),
        BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Coach'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), label: 'Log'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Life OS'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.of(context).pushReplacementNamed('/today');
            break;
          case 1:
            Navigator.of(context).pushReplacementNamed('/ai_coach');
            break;
          case 2:
            Navigator.of(context).pushReplacementNamed('/log');
            break;
          case 3:
            Navigator.of(context).pushReplacementNamed('/life-os');
            break;
          case 4:
            Navigator.of(context).pushReplacementNamed('/profile');
            break;
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/agentic_providers.dart';
import '../../core/services/agentic/agentic_discipline_engine.dart';

/// Karma XP Tracker Screen - Shows karma points and level progression
class KarmaTrackerScreen extends ConsumerWidget {
  const KarmaTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karmaAsync = ref.watch(karmaStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karma Points'),
      ),
      body: karmaAsync.when(
        data: (karma) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelCard(context, karma),
              const SizedBox(height: 24),
              _buildProgressCard(context, karma),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, KarmaStatus karma) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${karma.level}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Level ${karma.level}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${karma.currentKarma} Karma Points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.orange,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, KarmaStatus karma) {
    final progress = karma.progress;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress to Level ${karma.level + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Text(
              '${karma.currentKarma} / ${karma.nextLevelKarma}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earn Karma By',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildKarmaAction('Meditation', 10),
            _buildKarmaAction('Gratitude Journal', 5),
            _buildKarmaAction('Workout', 15),
            _buildKarmaAction('Service/Help', 20),
            _buildKarmaAction('Discipline (streak)', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildKarmaAction(String action, int points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(action)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$points',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


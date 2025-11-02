import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/agent_providers.dart';
import '../../core/models/bond_level.dart';

/// Bond Level Screen - Shows user-agent connection level
class BondLevelScreen extends ConsumerWidget {
  const BondLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bondAsync = ref.watch(bondLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bond Level'),
      ),
      body: bondAsync.when(
        data: (bond) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBondCard(context, bond),
              const SizedBox(height: 24),
              _buildFeaturesList(context, bond),
              const SizedBox(height: 24),
              _buildProgressInfo(context, bond),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBondCard(BuildContext context, BondLevel bond) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade300,
                    Colors.purple.shade600,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  bond.label.split(' ').first.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              bond.label,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              bond.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context, BondLevel bond) {
    final features = _getFeaturesForLevel(bond);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlocked Features',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context, BondLevel bond) {
    final nextLevel = _getNextLevel(bond);
    if (nextLevel == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'You\'ve reached the highest bond level!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Level: ${nextLevel.label}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Requires ${nextLevel.requiredDays} days of active engagement',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.5, // Would calculate actual progress
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getFeaturesForLevel(BondLevel bond) {
    switch (bond) {
      case BondLevel.basic:
        return [
          'Chat with agent',
          'Basic task tracking',
          'Workout logging',
        ];
      case BondLevel.interactive:
        return [
          'Real-time guidance',
          'AR workouts',
          'Voice interactions',
          'Camera mode',
        ];
      case BondLevel.evolving:
        return [
          'Emotional sync',
          'Deep mood analysis',
          'Predictive coaching',
          'Dream analysis',
        ];
      case BondLevel.merged:
        return [
          'Life twin mode',
          'Full daily rhythm design',
          'Agent-to-agent communication',
          'Advanced AI persona',
        ];
    }
  }

  BondLevel? _getNextLevel(BondLevel current) {
    switch (current) {
      case BondLevel.basic:
        return BondLevel.interactive;
      case BondLevel.interactive:
        return BondLevel.evolving;
      case BondLevel.evolving:
        return BondLevel.merged;
      case BondLevel.merged:
        return null;
    }
  }
}


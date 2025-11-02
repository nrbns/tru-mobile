import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/agent_providers.dart';
import '../../core/services/energy_pulse_service.dart';
import '../../widgets/progress_ring.dart';

/// Energy Pulse Screen - Visualizes mind-body balance (chakra-style)
class EnergyPulseScreen extends ConsumerWidget {
  const EnergyPulseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseAsync = ref.watch(energyPulseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Pulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info about energy pulse
            },
          ),
        ],
      ),
      body: pulseAsync.when(
        data: (pulse) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallBalance(context, pulse),
              const SizedBox(height: 24),
              _buildChakraVisualization(context, pulse),
              const SizedBox(height: 24),
              _buildDomainBreakdown(context, pulse),
              const SizedBox(height: 24),
              _buildInsights(context, pulse),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildOverallBalance(BuildContext context, EnergyPulse pulse) {
    final color = _getColorForState(pulse.state);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Overall Balance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 200,
              child: ProgressRing(
                progress: pulse.overallBalance,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${(pulse.overallBalance * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              pulse.state.name.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChakraVisualization(BuildContext context, EnergyPulse pulse) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chakra Energy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildChakraBar('Crown', 0.7, Colors.purple),
            _buildChakraBar('Third Eye', 0.8, Colors.indigo),
            _buildChakraBar('Throat', 0.6, Colors.blue),
            _buildChakraBar('Heart', pulse.mindEnergy, Colors.green),
            _buildChakraBar('Solar Plexus', 0.7, Colors.yellow),
            _buildChakraBar('Sacral', 0.6, Colors.orange),
            _buildChakraBar('Root', pulse.bodyEnergy, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildChakraBar(String name, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainBreakdown(BuildContext context, EnergyPulse pulse) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Domain Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDomainCard('Mind', pulse.mindEnergy, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDomainCard('Body', pulse.bodyEnergy, Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainCard(String name, double value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CircularProgressIndicator(
              value: value,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(BuildContext context, EnergyPulse pulse) {
    final insights = <String>[];
    
    if (pulse.overallBalance < 0.4) {
      insights.add('Your energy is low. Focus on recovery and rest.');
    } else if (pulse.mindEnergy < pulse.bodyEnergy * 0.7) {
      insights.add('Mind-body imbalance: Your body is active but mind needs care.');
    } else if (pulse.overallBalance > 0.8) {
      insights.add('Excellent balance! You\'re in peak condition.');
    }

    if (insights.isEmpty) {
      insights.add('You\'re maintaining good balance across domains.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(insight)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getColorForState(PulseState state) {
    switch (state) {
      case PulseState.peak:
        return Colors.green;
      case PulseState.balanced:
        return Colors.blue;
      case PulseState.low:
        return Colors.orange;
      case PulseState.critical:
        return Colors.red;
    }
  }
}


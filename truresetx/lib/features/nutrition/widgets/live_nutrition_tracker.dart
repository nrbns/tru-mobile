import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/live_data_providers.dart';

class LiveNutritionTracker extends ConsumerWidget {
  const LiveNutritionTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodLogs = ref.watch(liveFoodLogsProvider);
    final liveMetrics = ref.watch(liveNutritionTrackingProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withAlpha((0.1 * 255).round()),
            Colors.blue.withAlpha((0.1 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Nutrition Tracking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Real-time macro tracking',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's Nutrition Summary
          foodLogs.when(
            data: (logs) => _buildNutritionSummary(logs),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),

          const SizedBox(height: 20),

          // Live Data Stream
          liveMetrics.when(
            data: (metrics) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Live Nutrition Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Last update: ${DateTime.now().toString().substring(11, 19)}'),
                  if (metrics.isNotEmpty) ...[
                    Text('Live updates: ${metrics.length} received'),
                  ],
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(List<dynamic> logs) {
    // Calculate totals from logs
    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (final log in logs) {
      totalCalories += (log.calories ?? 0).toDouble();
      totalProtein += (log.protein ?? 0).toDouble();
      totalCarbs += (log.carbs ?? 0).toDouble();
      totalFat += (log.fat ?? 0).toDouble();
    }

    return Column(
      children: [
        // Macro Progress Bars
        _buildMacroProgress('Calories', totalCalories, 2000.0, Colors.red),
        const SizedBox(height: 12),
        _buildMacroProgress('Protein', totalProtein, 120.0, Colors.blue),
        const SizedBox(height: 12),
        _buildMacroProgress('Carbs', totalCarbs, 200.0, Colors.orange),
        const SizedBox(height: 12),
        _buildMacroProgress('Fat', totalFat, 80.0, Colors.green),
        const SizedBox(height: 20),

        // Quick Stats
        Row(
          children: [
            Expanded(
              child:
                  _buildQuickStat('Meals', '${logs.length}', Icons.restaurant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStat('Water', '2.5L', Icons.water_drop),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStat('Fiber', '25g', Icons.grain),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroProgress(
      String name, double current, double target, Color color) {
    final percentage = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${current.toInt()}/${target.toInt()}'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withAlpha((0.2 * 255).round()),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../data/providers/live_data_providers.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/supabase_service.dart';

class LiveDashboard extends ConsumerStatefulWidget {
  const LiveDashboard({super.key});

  @override
  ConsumerState<LiveDashboard> createState() => _LiveDashboardState();
}

class _LiveDashboardState extends ConsumerState<LiveDashboard> {
  @override
  void initState() {
    super.initState();
    // Initialize real-time service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supabase = ref.read(supabaseClientProvider);
      ref.read(realtimeServiceProvider).initialize(supabase);
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(liveConnectionStatusProvider);
    final userStats = ref.watch(liveUserStatsProvider);
    final weeklyProgress = ref.watch(liveWeeklyProgressProvider);
    final liveMetrics = ref.watch(liveMetricsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Status
          _buildConnectionStatus(connectionStatus),
          const SizedBox(height: 16),

          // Live Stats Cards
          _buildLiveStatsCards(userStats),
          const SizedBox(height: 16),

          // Weekly Progress Chart
          _buildWeeklyProgressChart(weeklyProgress),
          const SizedBox(height: 16),

          // Live Metrics
          _buildLiveMetrics(liveMetrics),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(AsyncValue<String> connectionStatus) {
    return connectionStatus.when(
      data: (status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: status.contains('connected')
              ? Colors.green.withAlpha((0.1 * 255).round())
              : Colors.red.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: status.contains('connected') ? Colors.green : Colors.red,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              status.contains('connected') ? Icons.wifi : Icons.wifi_off,
              color: status.contains('connected') ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              status.contains('connected')
                  ? 'Live Data Connected'
                  : 'Connecting...',
              style: TextStyle(
                color: status.contains('connected') ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildLiveStatsCards(AsyncValue<Map<String, dynamic>> userStats) {
    return userStats.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Workouts',
              '${stats['workout_count'] ?? 0}',
              Icons.fitness_center,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Meditations',
              '${stats['meditation_count'] ?? 0}',
              Icons.spa,
              Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Calories',
              '${stats['total_calories_burned'] ?? 0}',
              Icons.local_fire_department,
              Colors.orange,
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withAlpha((0.8 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart(
      AsyncValue<Map<String, dynamic>> weeklyProgress) {
    return weeklyProgress.when(
      data: (progress) => Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 7,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          return Text(days[value.toInt() % 7]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: (progress['workouts'] ?? 0).toDouble(),
                          color: Colors.blue,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY:
                              (progress['meditation_sessions'] ?? 0).toDouble(),
                          color: Colors.purple,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: (progress['mood_logs'] ?? 0).toDouble(),
                          color: Colors.green,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: (progress['workouts'] ?? 0).toDouble(),
                          color: Colors.orange,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY:
                              (progress['meditation_sessions'] ?? 0).toDouble(),
                          color: Colors.red,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: (progress['mood_logs'] ?? 0).toDouble(),
                          color: Colors.teal,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: (progress['workouts'] ?? 0).toDouble(),
                          color: Colors.indigo,
                          width: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildLiveMetrics(AsyncValue<Map<String, dynamic>> liveMetrics) {
    return liveMetrics.when(
      data: (metrics) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withAlpha((0.2 * 255).round())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Live Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (metrics.isNotEmpty) ...[
              Text('Heart Rate: ${metrics['heart_rate'] ?? '--'} BPM'),
              Text('Steps: ${metrics['steps'] ?? '--'}'),
              Text('Active Time: ${metrics['active_time'] ?? '--'} min'),
            ] else
              const Text('No live metrics available'),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

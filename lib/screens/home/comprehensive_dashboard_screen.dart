import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/nav_bar.dart';
import '../../core/providers/today_provider.dart';
import '../../core/providers/activity_provider.dart';
import '../../core/providers/gamification_provider.dart';
import '../../core/providers/analytics_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Comprehensive Real-Time Dashboard - Body + Mind + Spirit Metrics
class ComprehensiveDashboardScreen extends ConsumerWidget {
  const ComprehensiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayStreamProvider);
    final activityAsync = ref.watch(todayActivityProvider);
    final moodTrendsAsync = ref.watch(moodTrendsProvider);
    final nutritionTrendsAsync = ref.watch(nutritionTrendsProvider);
    final workoutTrendsAsync = ref.watch(workoutTrendsProvider);
    final spiritualTrendsAsync = ref.watch(spiritualTrendsProvider);
    final userLevelAsync = ref.watch(userLevelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.settings, color: Colors.white),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Level & XP
                    userLevelAsync.when(
                      data: (level) => _buildLevelCard(level),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Real-Time Metrics Grid
                    Row(
                      children: [
                        Expanded(
                          child: todayAsync.when(
                            data: (today) => _buildMetricCard(
                              'Mood',
                              '${today.mood.latest}',
                              '/10',
                              LucideIcons.heart,
                              AppColors.moodColor,
                              subtitle: 'Latest',
                            ),
                            loading: () => _buildMetricCard(
                              'Mood',
                              '-',
                              '/10',
                              LucideIcons.heart,
                              AppColors.moodColor,
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: todayAsync.when(
                            data: (today) => _buildMetricCard(
                              'Water',
                              (today.waterMl / 1000).toStringAsFixed(1),
                              'L',
                              LucideIcons.droplet,
                              AppColors.nutritionColor,
                              subtitle: 'Today',
                            ),
                            loading: () => _buildMetricCard(
                              'Water',
                              '-',
                              'L',
                              LucideIcons.droplet,
                              AppColors.nutritionColor,
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: activityAsync.when(
                            data: (activity) => _buildMetricCard(
                              'Steps',
                              '${activity?['steps'] ?? 0}',
                              '',
                              LucideIcons.activity,
                              AppColors.primary,
                              subtitle: 'Today',
                            ),
                            loading: () => _buildMetricCard(
                              'Steps',
                              '-',
                              '',
                              LucideIcons.activity,
                              AppColors.primary,
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: todayAsync.when(
                            data: (today) => _buildMetricCard(
                              'Workouts',
                              '${today.workouts.done}',
                              '/${today.workouts.target}',
                              LucideIcons.dumbbell,
                              AppColors.workoutColor,
                              subtitle: 'Today',
                            ),
                            loading: () => _buildMetricCard(
                              'Workouts',
                              '-',
                              '',
                              LucideIcons.dumbbell,
                              AppColors.workoutColor,
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Rings
                    todayAsync.when(
                      data: (today) => _buildProgressRings(today),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Trends Charts
                    _buildTrendsSection(
                      moodTrendsAsync,
                      nutritionTrendsAsync,
                      workoutTrendsAsync,
                      spiritualTrendsAsync,
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
            const NavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level) {
    final levelNum = level['level'] as int? ?? 1;
    final currentXP = level['current_xp'] as int? ?? 0;
    final xpToNext = level['xp_to_next_level'] as int? ?? 1000;
    final progress = currentXP / xpToNext;

    return AuraCard(
      variant: AuraCardVariant.ai,
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppColors.aiGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$levelNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Level',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentXP / $xpToNext XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRings(dynamic today) {
    return Row(
      children: [
        Expanded(
          child: ProgressRing(
            progress: (today.mood.latest / 10).clamp(0.0, 1.0),
            label: 'Mood',
            color: AppColors.moodColor,
            icon: LucideIcons.heart,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProgressRing(
            progress: (today.waterMl / 3000).clamp(0.0, 1.0),
            label: 'Water',
            color: AppColors.nutritionColor,
            icon: LucideIcons.droplet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProgressRing(
            progress:
                (today.workouts.done / today.workouts.target).clamp(0.0, 1.0),
            label: 'Workout',
            color: AppColors.workoutColor,
            icon: LucideIcons.dumbbell,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsSection(
    AsyncValue moodTrends,
    AsyncValue nutritionTrends,
    AsyncValue workoutTrends,
    AsyncValue spiritualTrends,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7-Day Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AuraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.heart,
                            color: AppColors.moodColor, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Mood',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: moodTrends.when(
                        data: (trends) =>
                            _buildMiniChart(trends, AppColors.moodColor),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error',
                            style: TextStyle(color: Colors.red)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.dumbbell,
                            color: AppColors.workoutColor, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Workouts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: workoutTrends.when(
                        data: (trends) =>
                            _buildMiniChart(trends, AppColors.workoutColor),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniChart(List<dynamic> data, Color color) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      );
    }

    // Extract values from trend data
    final values = data.map((d) {
      if (d is Map) {
        return d['value'] as num? ?? d['count'] as num? ?? 0.0;
      }
      return 0.0;
    }).toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue);
    final normalized = range > 0
        ? values.map((v) => ((v - minValue) / range).clamp(0.0, 1.0)).toList()
        : values.map((_) => 0.5).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: normalized.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withAlpha((0.1 * 255).round()),
            ),
          ),
        ],
        minY: 0,
        maxY: 1,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickActionButton(
              context,
              'Log Mood',
              LucideIcons.heart,
              AppColors.moodColor,
              () => context.push('/mind/mood-log'),
            ),
            _buildQuickActionButton(
              context,
              'Snap Meal',
              LucideIcons.camera,
              AppColors.nutritionColor,
              () => context.push('/home/nutrition-log'),
            ),
            _buildQuickActionButton(
              context,
              'Generate Workout',
              LucideIcons.dumbbell,
              AppColors.workoutColor,
              () => context.push('/home/workouts/generator'),
            ),
            _buildQuickActionButton(
              context,
              'Daily Practice',
              LucideIcons.sparkles,
              AppColors.spiritualColor,
              () => context.push('/spirit/daily-practice'),
            ),
            _buildQuickActionButton(
              context,
              'AI Coach',
              LucideIcons.bot,
              AppColors.aiColor,
              () => context.push('/home/chatbot'),
            ),
            _buildQuickActionButton(
              context,
              'Analytics',
              LucideIcons.barChart,
              AppColors.primary,
              () => context.push('/home/analytics'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AuraCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

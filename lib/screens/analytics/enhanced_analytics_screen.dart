import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/analytics_provider.dart';

class EnhancedAnalyticsScreen extends ConsumerWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correlationsAsync = ref.watch(correlationsProvider);
    final insightsAsync = ref.watch(crossDomainInsightsProvider);
    final weeklyComparisonAsync = ref.watch(weeklyComparisonProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                          'Analytics & Insights',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Cross-domain correlations',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
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
                    // Correlations
                    correlationsAsync.when(
                      data: (correlations) => AuraCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mood Correlations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCorrelationItem(
                              'Workout',
                              correlations['workout'] ?? 0.0,
                              LucideIcons.dumbbell,
                              AppColors.warning,
                            ),
                            const SizedBox(height: 12),
                            _buildCorrelationItem(
                              'Nutrition',
                              correlations['nutrition'] ?? 0.0,
                              LucideIcons.nutrition,
                              AppColors.nutritionColor,
                            ),
                            const SizedBox(height: 12),
                            _buildCorrelationItem(
                              'Hydration',
                              correlations['hydration'] ?? 0.0,
                              LucideIcons.droplet,
                              AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err',
                          style: const TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 16),
                    // Cross-domain Insights
                    insightsAsync.when(
                      data: (insights) {
                        if (insights.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return AuraCard(
                          variant: AuraCardVariant.ai,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.lightbulb,
                                      color: AppColors.primary, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'AI Insights',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...insights.map((insight) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            insight['message'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '💡 ${insight['suggestion'] ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    // Weekly Comparison
                    weeklyComparisonAsync.when(
                      data: (comparison) => AuraCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Week-over-Week',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildComparisonItem(
                              'Calories',
                              comparison['calories']?['this_week'] ?? 0.0,
                              comparison['calories']?['change_percent'] ?? 0.0,
                              'kcal',
                            ),
                            const SizedBox(height: 12),
                            _buildComparisonItem(
                              'Workouts',
                              comparison['workouts']?['this_week'] ?? 0.0,
                              comparison['workouts']?['change_percent'] ?? 0.0,
                              'sessions',
                            ),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationItem(
      String label, double correlation, IconData icon, Color color) {
    final strength = correlation.abs();
    String strengthText;
    Color strengthColor;

    if (strength > 0.7) {
      strengthText = 'Strong';
      strengthColor = AppColors.success;
    } else if (strength > 0.4) {
      strengthText = 'Moderate';
      strengthColor = AppColors.warning;
    } else {
      strengthText = 'Weak';
      strengthColor = Colors.grey;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: strength.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: strengthColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$strengthText (${(correlation * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem(
      String label, double thisWeek, double changePercent, String unit) {
    final isPositive = changePercent >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${thisWeek.toStringAsFixed(0)} $unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive
                ? AppColors.success.withAlpha((0.2 * 255).round())
                : AppColors.error.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                size: 16,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

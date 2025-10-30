import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/meal_plan_provider.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  int _selectedDays = 7;
  String? _selectedGoal;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final activePlanAsync = ref.watch(activeMealPlanProvider);
    final todayMealsAsync = ref.watch(todayMealsProvider);

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
                          'Meal Plans',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'AI-generated personalized plans',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(LucideIcons.plus, color: AppColors.primary),
                    onPressed: _showGenerateDialog,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: activePlanAsync.when(
                data: (plan) {
                  if (plan == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.mealPlanner,
                              color: Colors.grey[600], size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No active meal plan',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showGenerateDialog,
                            icon: const Icon(LucideIcons.sparkles),
                            label: const Text('Generate Meal Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plan Overview
                        AuraCard(
                          variant: AuraCardVariant.nutrition,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['plan_name'] ?? 'My Meal Plan',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${plan['days'] ?? 0} days • ${plan['total_calories_per_day'] ?? 0} kcal/day',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                ),
                              ),
                              if (plan['considerations'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    plan['considerations'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Today's Meals
                        todayMealsAsync.when(
                          data: (meals) {
                            if (meals.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No meals scheduled for today',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's Meals",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...meals.map((meal) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _buildMealCard(meal),
                                    )),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err',
                              style: const TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: $err',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final foods = meal['foods'] as List<dynamic>? ?? [];
    final totalKcal =
        foods.fold<int>(0, (sum, food) => sum + (food['kcal'] as int? ?? 0));

    return AuraCard(
      variant: AuraCardVariant.nutrition,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getMealIcon(meal['meal_type'] ?? ''),
                color: AppColors.nutritionColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (meal['meal_type'] ?? 'meal').toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.nutritionColor,
                      ),
                    ),
                    Text(
                      '$totalKcal kcal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...foods.map((food) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        food['name'] ?? 'Food',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${food['kcal'] ?? 0} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return LucideIcons.sunrise;
      case 'lunch':
        return LucideIcons.sun;
      case 'dinner':
        return LucideIcons.moon;
      default:
        return LucideIcons.mealPlanner;
    }
  }

  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Generate Meal Plan',
            style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Days:', style: TextStyle(color: Colors.white)),
              Slider(
                value: _selectedDays.toDouble(),
                min: 3,
                max: 30,
                divisions: 27,
                label: '$_selectedDays days',
                onChanged: (value) {
                  setState(() => _selectedDays = value.toInt());
                },
              ),
              const SizedBox(height: 16),
              const Text('Goal:', style: TextStyle(color: Colors.white)),
              Wrap(
                spacing: 8,
                children: [
                  'weight_loss',
                  'muscle_gain',
                  'maintenance',
                  'health'
                ].map((goal) {
                  return ChoiceChip(
                    label: Text(goal.replaceAll('_', ' ')),
                    selected: _selectedGoal == goal,
                    onSelected: (selected) {
                      setState(() => _selectedGoal = selected ? goal : null);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isGenerating ? null : () => _generatePlan(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePlan(BuildContext dialogContext) async {
    setState(() => _isGenerating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.generateMealPlan(
        days: _selectedDays,
        goal: _selectedGoal,
      );

      if (!mounted) return;
      // Use the state context to close the dialog and show a snackbar safely.
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Meal plan generated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to generate plan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

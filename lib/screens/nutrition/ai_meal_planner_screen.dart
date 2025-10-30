import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/providers/meal_plan_provider.dart';
// Removed unused import: meal_plan_service is not used in this screen.

class AIMealPlannerScreen extends ConsumerWidget {
  const AIMealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanAsync = ref.watch(activeMealPlanProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'AI Meal Planner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: activePlanAsync.when(
                data: (plan) {
                  if (plan == null) {
                    return _emptyState(context, ref);
                  }
                  final days = (plan['days'] as List?) ?? [];
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index] as Map<String, dynamic>? ?? {};
                      final meals = (day['meals'] as List?) ?? [];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...meals.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.utensils,
                                          color: AppColors.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          (m['name'] ?? 'Meal') as String,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      Text('${m['kcal'] ?? 0} kcal',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _generatePlan(context, ref);
        },
        backgroundColor: AppColors.primary,
        label: const Text('Generate Plan'),
        icon: const Icon(LucideIcons.magicWand),
      ),
    );
  }

  Widget _emptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No active plan yet', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await _generatePlan(context, ref);
            },
            icon: const Icon(LucideIcons.magicWand),
            label: const Text('Generate 7-day Plan'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePlan(BuildContext context, WidgetRef ref) async {
    final service = ref.read(mealPlanServiceProvider);
    try {
      await service.generateMealPlan(days: 7, goal: 'maintenance');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan generated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}

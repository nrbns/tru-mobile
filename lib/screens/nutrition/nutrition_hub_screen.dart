import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class NutritionHubScreen extends StatelessWidget {
  const NutritionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Nutrition',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Quick links',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _tile(context, 'Meal Planner', LucideIcons.mealPlanner,
                      AppColors.nutritionColor, '/home/meal-planner'),
                  _tile(context, 'Nutrition Log', LucideIcons.nutrition,
                      AppColors.success, '/home/nutrition-log'),
                  _tile(context, 'Grocery List', LucideIcons.bookOpen,
                      AppColors.warning, '/home/grocery-list'),
                  _tile(context, 'Fasting Mode', LucideIcons.droplet,
                      AppColors.secondary, '/home/fasting-mode'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String label, IconData icon, Color color,
      String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withAlpha((0.18 * 255).round()),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(label, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}

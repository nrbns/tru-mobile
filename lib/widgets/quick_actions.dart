import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const List<_ActionItem> _actions = [
    _ActionItem(
      id: 'mood-log',
      label: 'Log Mood',
      icon: LucideIcons.heart,
      color: AppColors.primary,
      route: '/mind/mood-log',
    ),
    _ActionItem(
      id: 'water-tracker',
      label: 'Water',
      icon: LucideIcons.droplet,
      color: AppColors.cyan,
      route: '/home/water-tracker',
    ),
    _ActionItem(
      id: 'workouts',
      label: 'Workout',
      icon: LucideIcons.dumbbell,
      color: AppColors.success,
      route: '/home/workouts',
    ),
    _ActionItem(
      id: 'daily-practice',
      label: 'Practice',
      icon: LucideIcons.sparkles,
      color: AppColors.secondary,
      route: '/spirit/daily-practice',
    ),
    _ActionItem(
      id: 'cbt-journal',
      label: 'Journal',
      icon: LucideIcons.bookOpen,
      color: AppColors.warning,
      route: '/mind/cbt-journal',
    ),
    _ActionItem(
      id: 'weekly-progress',
      label: 'Progress',
      icon: LucideIcons.trendingUp,
      color: AppColors.error,
      route: '/home/weekly-progress',
    ),
    _ActionItem(
      id: 'chatbot',
      label: 'AI Coach',
      icon: LucideIcons.bot,
      color: AppColors.primary,
      route: '/home/chatbot',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _actions.length,
          itemBuilder: (context, index) {
            final action = _actions[index];
            return _ActionButton(
              action: action,
              onTap: () => context.push(action.route),
            );
          },
        ),
      ],
    );
  }
}

class _ActionItem {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _ActionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _ActionButton extends StatelessWidget {
  final _ActionItem action;
  final VoidCallback onTap;

  const _ActionButton({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: action.color.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                size: 24,
                color: action.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

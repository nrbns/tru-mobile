import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class SetupGoalsScreen extends StatefulWidget {
  const SetupGoalsScreen({super.key});

  @override
  State<SetupGoalsScreen> createState() => _SetupGoalsScreenState();
}

class _SetupGoalsScreenState extends State<SetupGoalsScreen> {
  final Set<String> _selectedGoals = {};

  final List<_Goal> _goals = const [
    _Goal(
      id: 'mental',
      title: 'Mental Wellness',
      description: 'Improve mood and reduce stress',
      icon: LucideIcons.brain,
      color: AppColors.primary,
    ),
    _Goal(
      id: 'spiritual',
      title: 'Spiritual Growth',
      description: 'Deepen your faith and practice',
      icon: LucideIcons.heart,
      color: AppColors.secondary,
    ),
    _Goal(
      id: 'fitness',
      title: 'Fitness & Health',
      description: 'Build strength and stamina',
      icon: LucideIcons.dumbbell,
      color: AppColors.success,
    ),
    _Goal(
      id: 'nutrition',
      title: 'Nutrition',
      description: 'Eat healthier and stay hydrated',
      icon: LucideIcons.droplet,
      color: AppColors.cyan,
    ),
  ];

  void _toggleGoal(String goalId) {
    setState(() {
      if (_selectedGoals.contains(goalId)) {
        _selectedGoals.remove(goalId);
      } else {
        _selectedGoals.add(goalId);
      }
    });
  }

  void _handleContinue() {
    if (_selectedGoals.isNotEmpty) {
      context.go('/belief-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What are your goals?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select all that apply. You can change this later.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Goals List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = _selectedGoals.contains(goal.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => _toggleGoal(goal.id),
                      child: AuraCard(
                        variant: isSelected
                            ? AuraCardVariant.default_
                            : AuraCardVariant.default_,
                        glow: isSelected,
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color:
                                    goal.color.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                goal.icon,
                                color: goal.color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? LucideIcons.checkCircle
                                  : LucideIcons.circle,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedGoals.isNotEmpty ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Goal {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

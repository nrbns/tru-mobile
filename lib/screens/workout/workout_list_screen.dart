import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Strength',
    'Cardio',
    'Flexibility',
    'Recovery'
  ];

  final List<_Workout> _workouts = const [
    _Workout(
      id: 'morning-strength',
      title: 'Morning Strength',
      category: 'Strength',
      duration: '30 min',
      difficulty: 'Intermediate',
      calories: '250 cal',
      emoji: '🏋️',
    ),
    _Workout(
      id: 'hiit-cardio',
      title: 'HIIT Cardio Blast',
      category: 'Cardio',
      duration: '20 min',
      difficulty: 'Advanced',
      calories: '300 cal',
      emoji: '🔥',
    ),
    _Workout(
      id: 'yoga-flow',
      title: 'Yoga Flow',
      category: 'Flexibility',
      duration: '45 min',
      difficulty: 'Beginner',
      calories: '150 cal',
      emoji: '🧘',
    ),
    _Workout(
      id: 'core-blast',
      title: 'Core Blast',
      category: 'Strength',
      duration: '15 min',
      difficulty: 'Intermediate',
      calories: '120 cal',
      emoji: '💪',
    ),
    _Workout(
      id: 'full-body',
      title: 'Full Body Burn',
      category: 'Strength',
      duration: '40 min',
      difficulty: 'Advanced',
      calories: '350 cal',
      emoji: '🔥',
    ),
  ];

  List<_Workout> get _filteredWorkouts {
    if (_selectedCategory == 'All') return _workouts;
    return _workouts.where((w) => w.category == _selectedCategory).toList();
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
              padding: const EdgeInsets.all(16.0),
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
                          'Workouts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Choose your training',
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
                    onPressed: () => context.push('/home/workouts/generator'),
                    tooltip: 'Create Workout',
                  ),
                ],
              ),
            ),
            // Category Filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.border,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGlow,
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Weekly Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AuraCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const _StatItem(
                        icon: LucideIcons.dumbbell,
                        label: '3',
                        subtitle: 'This week'),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    const _StatItem(
                        icon: LucideIcons.flame,
                        label: '850',
                        subtitle: 'Calories'),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    const _StatItem(
                        icon: LucideIcons.clock,
                        label: '105',
                        subtitle: 'Minutes'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Workout List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = _filteredWorkouts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withAlpha((0.1 * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    workout.emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.clock,
                                          size: 14,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          workout.duration,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getDifficultyColor(
                                                    workout.difficulty)
                                                .withAlpha((0.2 * 255).round()),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            workout.difficulty,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _getDifficultyColor(
                                                  workout.difficulty),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    workout.calories,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.push('/home/workouts/player',
                                          extra: {
                                            'name': workout.title,
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.play, size: 16),
                                        SizedBox(width: 4),
                                        Text('Start'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

class _Workout {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String difficulty;
  final String calories;
  final String emoji;

  const _Workout({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.emoji,
  });
}

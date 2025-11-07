import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/body_map_widget.dart';
import '../../core/providers/workout_library_provider.dart';

class WorkoutGeneratorWizardScreen extends ConsumerStatefulWidget {
  const WorkoutGeneratorWizardScreen({super.key});

  @override
  ConsumerState<WorkoutGeneratorWizardScreen> createState() =>
      _WorkoutGeneratorWizardScreenState();
}

class _WorkoutGeneratorWizardScreenState
    extends ConsumerState<WorkoutGeneratorWizardScreen> {
  int _currentStep = 0;

  // Step 1: Goal
  String? _selectedGoal;

  // Step 2: Equipment
  final Set<String> _selectedEquipment = {};

  // Step 3: Body Map
  final List<String> _selectedMuscleGroups = [];

  // Step 4: Filters
  String? _selectedDifficulty;
  bool? _compoundOnly;
  bool? _isolationOnly;

  // Step 5: Duration & Exercise Count
  int _durationMinutes = 30;
  int? _exactExerciseCount;

  bool _isGenerating = false;
  Map<String, dynamic>? _generatedWorkout;

  final List<String> _goals = [
    'muscle_gain',
    'weight_loss',
    'general_fitness',
    'stress_relief',
    'mobility',
  ];

  final Map<String, String> _goalLabels = {
    'muscle_gain': 'Muscle Gain',
    'weight_loss': 'Weight Loss',
    'general_fitness': 'General Fitness',
    'stress_relief': 'Stress Relief',
    'mobility': 'Mobility',
  };

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final equipment = await ref.read(equipmentTypesProvider.future);
    setState(() {
      // Pre-select common equipment
      if (equipment.contains('bodyweight')) {
        _selectedEquipment.add('bodyweight');
      }
    });
  }

  Future<void> _generateWorkout() async {
    if (_selectedGoal == null || _selectedEquipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select goal and equipment')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final generator = ref.read(enhancedWorkoutGeneratorProvider);
      final workout = await generator.generateWorkout(
        goal: _selectedGoal!,
        equipment: _selectedEquipment.toList(),
        durationMinutes: _durationMinutes,
        targetMuscleGroups:
            _selectedMuscleGroups.isNotEmpty ? _selectedMuscleGroups : null,
        exactExerciseCount: _exactExerciseCount,
        difficulty: _selectedDifficulty,
        compoundOnly: _compoundOnly,
        isolationOnly: _isolationOnly,
        includeMoodAdaptation: true,
        includeSpiritIntegration: true,
      );

      // Add workout ID for logging
      final workoutWithId = {
        ...workout,
        'id': 'workout_${DateTime.now().millisecondsSinceEpoch}',
        'exercises': workout['exercises'] ?? [],
      };

      setState(() {
        _generatedWorkout = workoutWithId;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate workout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_generatedWorkout != null) {
      return _buildWorkoutResult();
    }

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
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Workout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Step ${_currentStep + 1} of 5',
                          style: const TextStyle(
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
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStepContent(),
              ),
            ),
            // Navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _currentStep == 4
                        ? (_isGenerating ? null : _generateWorkout)
                        : () {
                            if (_validateCurrentStep()) {
                              setState(() => _currentStep++);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _currentStep == 4
                        ? (_isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Generate Workout'))
                        : const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildGoalStep();
      case 1:
        return _buildEquipmentStep();
      case 2:
        return _buildBodyMapStep();
      case 3:
        return _buildFiltersStep();
      case 4:
        return _buildDurationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGoalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your goal?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ..._goals.map((goal) {
          final isSelected = _selectedGoal == goal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AuraCard(
              variant: isSelected
                  ? AuraCardVariant.default_
                  : AuraCardVariant.default_,
              glow: isSelected,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedGoal = goal);
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha((0.2 * 255).round())
                            : AppColors.textMuted
                                .withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.target,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _goalLabels[goal] ?? goal,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        LucideIcons.checkCircle,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEquipmentStep() {
    return FutureBuilder<List<String>>(
      future: ref.read(equipmentTypesProvider.future),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final equipment = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Equipment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: equipment.map((item) {
                final isSelected = _selectedEquipment.contains(item);
                return FilterChip(
                  selected: isSelected,
                  label: Text(item),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEquipment.add(item);
                      } else {
                        _selectedEquipment.remove(item);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
            if (_selectedEquipment.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Select at least one equipment type',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBodyMapStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Muscle Groups',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Optional - Leave empty for full body',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        BodyMapWidget(
          initialSelection: _selectedMuscleGroups,
          onSelectionChanged: (selected) {
            setState(() {
              _selectedMuscleGroups.clear();
              _selectedMuscleGroups.addAll(selected);
            });
          },
          multiSelect: true,
        ),
      ],
    );
  }

  Widget _buildFiltersStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Filters',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // Difficulty
        AuraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Difficulty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['beginner', 'intermediate', 'advanced'].map((diff) {
                  final isSelected = _selectedDifficulty == diff;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedDifficulty = diff);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                    .withAlpha((0.2 * 255).round())
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              diff.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Compound/Isolation
        AuraCard(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Compound Movements Only',
                    style: TextStyle(color: Colors.white)),
                value: _compoundOnly ?? false,
                onChanged: (value) {
                  setState(() {
                    _compoundOnly = value;
                    if (value) _isolationOnly = false;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('Isolation Movements Only',
                    style: TextStyle(color: Colors.white)),
                value: _isolationOnly ?? false,
                onChanged: (value) {
                  setState(() {
                    _isolationOnly = value;
                    if (value) _compoundOnly = false;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration & Exercise Count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // Duration
        AuraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duration: $_durationMinutes minutes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Slider(
                value: _durationMinutes.toDouble(),
                min: 10,
                max: 90,
                divisions: 16,
                label: '$_durationMinutes min',
                onChanged: (value) {
                  setState(() => _durationMinutes = value.round());
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Exercise Count
        AuraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Number of Exercises',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _exactExerciseCount?.toString() ?? 'Auto',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value:
                    (_exactExerciseCount ?? (_durationMinutes ~/ 5)).toDouble(),
                min: 3,
                max: 20,
                divisions: 17,
                label: _exactExerciseCount?.toString() ?? 'Auto',
                onChanged: (value) {
                  setState(() => _exactExerciseCount = value.round());
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _exactExerciseCount = null);
                    },
                    child: const Text('Auto (Recommended)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutResult() {
    final workout = _generatedWorkout!;
    final exercises = (workout['exercises'] as List?) ?? [];
    final warmup = (workout['warmup'] as List?) ?? [];
    final cooldown = (workout['cooldown'] as List?) ?? [];

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
                    onPressed: () {
                      setState(() => _generatedWorkout = null);
                    },
                  ),
                  Expanded(
                    child: Text(
                      workout['name'] ?? 'Generated Workout',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(LucideIcons.play, color: AppColors.primary),
                    onPressed: () {
                      // Navigate to workout action screen with generated workout
                      context.push(
                        '/home/workouts/action?'
                        'workoutId=${workout['id'] ?? 'generated'}&'
                        'workoutName=${Uri.encodeComponent(workout['name'] ?? 'Workout')}&'
                        'duration=${workout['duration_minutes'] ?? 30} min&'
                        'difficulty=${workout['difficulty'] ?? 'intermediate'}&'
                        'calories=${workout['calories_estimate'] ?? 200} cal&'
                        'emoji=💪',
                      );
                    },
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
                    // Workout Info
                    AuraCard(
                      glow: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout['name'] ?? 'Workout',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (workout['rationale'] != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              workout['rationale'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoChip(
                                  '${workout['duration_minutes']} min',
                                  LucideIcons.clock),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                  workout['difficulty'] ?? 'intermediate',
                                  LucideIcons.zap),
                              const SizedBox(width: 8),
                              _buildInfoChip('${exercises.length} exercises',
                                  LucideIcons.activity),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Warmup
                    if (warmup.isNotEmpty) ...[
                      const Text(
                        'Warm-up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...warmup.map(
                          (item) => _buildExerciseCard(item, isWarmup: true)),
                      const SizedBox(height: 16),
                    ],
                    // Main Exercises
                    const Text(
                      'Exercises',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...exercises.asMap().entries.map((entry) {
                      return _buildExerciseCard(entry.value,
                          index: entry.key + 1);
                    }),
                    // Cooldown
                    if (cooldown.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Cool-down',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...cooldown.map(
                          (item) => _buildExerciseCard(item, isCooldown: true)),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Start Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/home/workouts/action?'
                      'workoutId=${workout['id'] ?? 'generated'}&'
                      'workoutName=${Uri.encodeComponent(workout['name'] ?? 'Workout')}&'
                      'duration=${workout['duration_minutes'] ?? 30} min&'
                      'difficulty=${workout['difficulty'] ?? 'intermediate'}&'
                      'calories=${workout['calories_estimate'] ?? 200} cal&'
                      'emoji=💪',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.play, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Start Workout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(dynamic exercise,
      {int? index, bool isWarmup = false, bool isCooldown = false}) {
    final name =
        exercise['exercise_name'] ?? exercise['exercise'] ?? 'Exercise';
    final duration = exercise['duration_sec'];
    final sets = exercise['sets'];
    final reps = exercise['reps'];
    final rest = exercise['rest_sec'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        child: Row(
          children: [
            if (index != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else if (isWarmup || isCooldown)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isWarmup ? LucideIcons.zap : LucideIcons.moon,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
            if (index != null || isWarmup || isCooldown)
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (sets != null && reps != null)
                        Text(
                          '$sets sets × $reps reps',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      if (duration != null)
                        Text(
                          '${duration}sec',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      if (rest != null && sets != null)
                        Text(
                          ' • ${rest}sec rest',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon:
                  const Icon(LucideIcons.playCircle, color: AppColors.primary),
              onPressed: () {
                // Show video demo
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedGoal != null;
      case 1:
        return _selectedEquipment.isNotEmpty;
      default:
        return true;
    }
  }
}

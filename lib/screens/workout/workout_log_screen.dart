import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/workout_library_provider.dart';

class WorkoutLogScreen extends ConsumerStatefulWidget {
  final String workoutPlanId;
  final List<Map<String, dynamic>> exercises;

  const WorkoutLogScreen({
    super.key,
    required this.workoutPlanId,
    this.exercises = const [],
  });

  @override
  ConsumerState<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen> {
  final Map<String, List<Map<String, dynamic>>> _exerciseLogs = {};
  int? _moodBefore;
  int? _moodAfter;
  final TextEditingController _notesController = TextEditingController();
  List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _exercises = widget.exercises;
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    if (widget.exercises.isEmpty) {
      // Try to load exercises from saved workout plan
      try {
        // Get workout plans collection
        final firestore = FirebaseFirestore.instance;
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // No authenticated user; fall back to provided exercises
          print('No authenticated user while loading workout plan');
          setState(() {
            _exercises = widget.exercises;
          });
          return;
        }
        final uid = currentUser.uid;

        final plansSnapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('workout_plans')
            .where('id', isEqualTo: widget.workoutPlanId)
            .limit(1)
            .get();

        if (plansSnapshot.docs.isNotEmpty) {
          final planData =
              plansSnapshot.docs.first.data() as Map<String, dynamic>? ?? {};
          final exercises = planData['exercises'] as List? ?? [];
          if (exercises.isNotEmpty) {
            setState(() {
              _exercises =
                  exercises.map((e) => Map<String, dynamic>.from(e)).toList();
            });
          }
        }
      } catch (e) {
        print('Failed to load workout plan: $e');
        // If loading fails, use default exercises
        setState(() {
          _exercises = widget.exercises;
        });
      }
    } else {
      _exercises = widget.exercises;
    }
  }

  void _logExerciseSet(
    String exerciseId,
    String exerciseName, {
    int? sets,
    dynamic reps,
    double? weight,
    int? duration,
  }) {
    if (!_exerciseLogs.containsKey(exerciseId)) {
      _exerciseLogs[exerciseId] = [];
    }

    setState(() {
      _exerciseLogs[exerciseId]!.add({
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'duration': duration,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _saveWorkoutLog() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final exercisesCompleted =
          _exerciseLogs.values.expand((sets) => sets).toList();

      if (exercisesCompleted.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log at least one exercise')),
        );
        return;
      }

      final generator = ref.read(enhancedWorkoutGeneratorProvider);
      await generator.logWorkout(
        workoutPlanId: widget.workoutPlanId,
        exercisesCompleted: exercisesCompleted,
        moodBefore: _moodBefore,
        moodAfter: _moodAfter,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Workout logged successfully!')),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to log workout: $e')),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      'Log Workout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(LucideIcons.check, color: AppColors.primary),
                    onPressed: _saveWorkoutLog,
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
                    // Mood Tracking
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mood Tracking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Before Workout',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 10,
                                        itemBuilder: (context, index) {
                                          final mood = index + 1;
                                          final isSelected =
                                              _moodBefore == mood;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(
                                                  () => _moodBefore = mood);
                                            },
                                            child: Container(
                                              width: 40,
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.border,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$mood',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors
                                                            .textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'After Workout',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 10,
                                        itemBuilder: (context, index) {
                                          final mood = index + 1;
                                          final isSelected = _moodAfter == mood;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() => _moodAfter = mood);
                                            },
                                            child: Container(
                                              width: 40,
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.secondary
                                                    : AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.secondary
                                                      : AppColors.border,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$mood',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors
                                                            .textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Exercises
                    const Text(
                      'Exercises',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(_exercises.isNotEmpty
                            ? _exercises
                            : [
                                {
                                  'exercise_name': 'Exercise 1',
                                  'sets': 3,
                                  'reps': 10
                                },
                                {
                                  'exercise_name': 'Exercise 2',
                                  'sets': 3,
                                  'reps': 12
                                },
                              ])
                        .asMap()
                        .entries
                        .map((entry) {
                      final exercise = entry.value;
                      final index = entry.key;
                      final exerciseId = exercise['exercise_id'] ?? 'ex_$index';
                      final exerciseName = exercise['exercise_name'] ??
                          exercise['exercise'] ??
                          'Exercise';
                      final sets = exercise['sets'] as int?;
                      final reps = exercise['reps'];
                      final weight = exercise['weight'] as double?;
                      final duration = exercise['duration_sec'] as int?;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseLogCard(
                          exerciseId: exerciseId.toString(),
                          exerciseName: exerciseName,
                          defaultSets: sets,
                          defaultReps: reps,
                          defaultWeight: weight,
                          defaultDuration: duration,
                          onLogSet: (sets, reps, weight, duration) {
                            _logExerciseSet(
                              exerciseId.toString(),
                              exerciseName,
                              sets: sets,
                              reps: reps,
                              weight: weight,
                              duration: duration,
                            );
                          },
                          loggedSets:
                              _exerciseLogs[exerciseId.toString()] ?? [],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Notes
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'How did the workout feel?',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseLogCard extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final int? defaultSets;
  final dynamic defaultReps;
  final double? defaultWeight;
  final int? defaultDuration;
  final Function(int?, dynamic, double?, int?) onLogSet;
  final List<Map<String, dynamic>> loggedSets;

  const _ExerciseLogCard({
    required this.exerciseId,
    required this.exerciseName,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultWeight,
    required this.defaultDuration,
    required this.onLogSet,
    required this.loggedSets,
  });

  @override
  State<_ExerciseLogCard> createState() => _ExerciseLogCardState();
}

class _ExerciseLogCardState extends State<_ExerciseLogCard> {
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setsController.text = widget.defaultSets?.toString() ?? '';
    _repsController.text = widget.defaultReps?.toString() ?? '';
    _weightController.text = widget.defaultWeight?.toString() ?? '';
    _durationController.text = widget.defaultDuration?.toString() ?? '';
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addSet() {
    final sets = _setsController.text.isEmpty
        ? null
        : int.tryParse(_setsController.text);
    final reps = _repsController.text.isEmpty ? null : _repsController.text;
    final weight = _weightController.text.isEmpty
        ? null
        : double.tryParse(_weightController.text);
    final duration = _durationController.text.isEmpty
        ? null
        : int.tryParse(_durationController.text);

    widget.onLogSet(sets, reps, weight, duration);

    // Clear inputs
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.exerciseName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Input fields
          Row(
            children: [
              if (widget.defaultSets != null || widget.defaultReps != null) ...[
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Sets',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (widget.defaultWeight != null) ...[
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (widget.defaultDuration != null) ...[
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (sec)',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: const Icon(LucideIcons.plusCircle,
                    color: AppColors.primary),
                onPressed: _addSet,
                tooltip: 'Add Set',
              ),
            ],
          ),
          // Logged sets
          if (widget.loggedSets.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...widget.loggedSets.asMap().entries.map((entry) {
              final set = entry.value;
              final setNumber = entry.key + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Set $setNumber: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    if (set['sets'] != null)
                      Text('${set['sets']} sets ',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    if (set['reps'] != null)
                      Text('${set['reps']} reps ',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    if (set['weight'] != null)
                      Text('${set['weight']} kg ',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    if (set['duration'] != null)
                      Text('${set['duration']} sec',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

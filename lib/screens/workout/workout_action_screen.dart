import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class WorkoutActionScreen extends StatefulWidget {
  final String workoutId;
  final String workoutName;
  final String duration;
  final String difficulty;
  final String calories;
  final String emoji;
  final List<Map<String, dynamic>>?
      exercises; // Optional AI-generated exercises

  const WorkoutActionScreen({
    super.key,
    required this.workoutId,
    required this.workoutName,
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.emoji,
    this.exercises,
  });

  @override
  State<WorkoutActionScreen> createState() => _WorkoutActionScreenState();
}

class _WorkoutActionScreenState extends State<WorkoutActionScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _restMode = false;
  int _restSeconds = 0;

  // Default exercises if not provided
  List<Map<String, dynamic>> get _exercises {
    if (widget.exercises != null && widget.exercises!.isNotEmpty) {
      return widget.exercises!;
    }

    // Default exercises based on workout type
    switch (widget.workoutId) {
      case 'hiit-cardio':
        return [
          {
            'name': 'Jumping Jacks',
            'sets': 3,
            'reps': 30,
            'rest_sec': 30,
            'type': 'cardio'
          },
          {
            'name': 'Burpees',
            'sets': 3,
            'reps': 10,
            'rest_sec': 45,
            'type': 'cardio'
          },
          {
            'name': 'Mountain Climbers',
            'sets': 3,
            'reps': 20,
            'rest_sec': 30,
            'type': 'cardio'
          },
          {
            'name': 'High Knees',
            'sets': 3,
            'reps': 30,
            'rest_sec': 30,
            'type': 'cardio'
          },
          {
            'name': 'Sprint in Place',
            'sets': 3,
            'reps': 30,
            'rest_sec': 45,
            'type': 'cardio'
          },
        ];
      case 'yoga-flow':
        return [
          {'name': 'Downward Dog', 'duration_sec': 60, 'type': 'yoga'},
          {'name': 'Warrior I', 'duration_sec': 45, 'type': 'yoga'},
          {'name': 'Warrior II', 'duration_sec': 45, 'type': 'yoga'},
          {'name': 'Tree Pose', 'duration_sec': 60, 'type': 'yoga'},
          {'name': 'Child\'s Pose', 'duration_sec': 30, 'type': 'yoga'},
        ];
      case 'core-blast':
        return [
          {
            'name': 'Plank',
            'sets': 3,
            'duration_sec': 30,
            'rest_sec': 20,
            'type': 'strength'
          },
          {
            'name': 'Russian Twists',
            'sets': 3,
            'reps': 20,
            'rest_sec': 20,
            'type': 'strength'
          },
          {
            'name': 'Bicycle Crunches',
            'sets': 3,
            'reps': 30,
            'rest_sec': 20,
            'type': 'strength'
          },
          {
            'name': 'Leg Raises',
            'sets': 3,
            'reps': 15,
            'rest_sec': 20,
            'type': 'strength'
          },
        ];
      case 'full-body-burn':
        return [
          {
            'name': 'Squats',
            'sets': 4,
            'reps': 15,
            'rest_sec': 30,
            'type': 'strength'
          },
          {
            'name': 'Push-ups',
            'sets': 4,
            'reps': 12,
            'rest_sec': 30,
            'type': 'strength'
          },
          {
            'name': 'Lunges',
            'sets': 3,
            'reps': 12,
            'rest_sec': 30,
            'type': 'strength'
          },
          {
            'name': 'Plank',
            'sets': 3,
            'duration_sec': 45,
            'rest_sec': 30,
            'type': 'strength'
          },
          {
            'name': 'Jumping Jacks',
            'sets': 3,
            'reps': 25,
            'rest_sec': 20,
            'type': 'cardio'
          },
        ];
      default:
        return [
          {'name': 'Warm-up', 'duration_sec': 300, 'type': 'warmup'},
          {
            'name': 'Exercise 1',
            'sets': 3,
            'reps': 10,
            'rest_sec': 30,
            'type': 'strength'
          },
          {
            'name': 'Exercise 2',
            'sets': 3,
            'reps': 10,
            'rest_sec': 30,
            'type': 'strength'
          },
          {'name': 'Cooldown', 'duration_sec': 300, 'type': 'cooldown'},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1), // Max 1 hour
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timerController.repeat();
    _updateTimer();
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timerController.stop();
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timerController.repeat();
  }

  void _updateTimer() {
    if (_isRunning) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isRunning) {
          setState(() {
            _elapsedSeconds++;

            // Handle rest timer
            if (_restMode && _restSeconds > 0) {
              _restSeconds--;
              if (_restSeconds == 0) {
                _restMode = false;
              }
            }
          });
          _updateTimer();
        }
      });
    }
  }

  void _nextExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentSet = 1;
      _restMode = false;
    });
  }

  void _completeSet() {
    final exercise = _exercises[_currentExerciseIndex];
    final sets = exercise['sets'] as int? ?? 1;

    if (_currentSet < sets) {
      setState(() {
        _currentSet++;
        _restMode = true;
        _restSeconds = exercise['rest_sec'] as int? ?? 30;
      });
      _startRestTimer();
    } else {
      if (_currentExerciseIndex < _exercises.length - 1) {
        _nextExercise();
      } else {
        _completeWorkout();
      }
    }
  }

  void _startRestTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _restMode && _restSeconds > 0) {
        setState(() {
          _restSeconds--;
        });
        _startRestTimer();
      } else if (mounted && _restSeconds == 0) {
        setState(() {
          _restMode = false;
        });
      }
    });
  }

  void _completeWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '🎉 Workout Complete!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Great job completing ${widget.workoutName}!',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: ${_formatTime(_elapsedSeconds)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Calories: ${widget.calories}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to workout log screen - exercises will be loaded from workout plan
              context.push(
                '/home/workout-log?workoutPlanId=${widget.workoutId}',
              );
            },
            child: const Text('Log Workout',
                style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Done', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get exercisesForLog => _exercises;

  @override
  Widget build(BuildContext context) {
    final currentExercise = _currentExerciseIndex < _exercises.length
        ? _exercises[_currentExerciseIndex]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () {
                      final rootContext = context;
                      if (_isRunning) {
                        showDialog(
                          context: rootContext,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('Pause Workout?',
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                'Are you sure you want to leave?',
                                style: TextStyle(color: Colors.grey)),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  // Use the captured rootContext to navigate the app (avoid using dialog context after the async gap)
                                  rootContext.pop();
                                },
                                child: const Text('Leave',
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        context.pop();
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.workoutName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_currentExerciseIndex + 1} of ${_exercises.length} exercises',
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
            ),

            // Timer Display
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGlow.withAlpha((0.3 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _restMode ? 'REST' : 'EXERCISE TIME',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha((0.8 * 255).round()),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _isRunning ? _pulseController : _timerController,
                    builder: (context, child) {
                      return Text(
                        _restMode
                            ? _formatTime(_restSeconds)
                            : _formatTime(_elapsedSeconds),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: _isRunning
                              ? [
                                  Shadow(
                                    color: Colors.white.withAlpha(((0.5 +
                                                (_pulseController.value *
                                                    0.2)) *
                                            255)
                                        .round()),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    },
                  ),
                  if (_restMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Next: Set $_currentSet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Current Exercise
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentExercise != null) ...[
                      AuraCard(
                        variant: AuraCardVariant.ai,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentExercise['name'] as String? ??
                                            'Exercise',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (currentExercise['reps'] != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withAlpha(
                                                        (0.2 * 255).round()),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${currentExercise['reps']} reps',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          if (currentExercise['sets'] !=
                                              null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary
                                                    .withAlpha(
                                                        (0.2 * 255).round()),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Set $_currentSet/${currentExercise['sets']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.secondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (currentExercise['duration_sec'] !=
                                              null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withAlpha(
                                                    (0.2 * 255).round()),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${(currentExercise['duration_sec'] as int) ~/ 60} min',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress indicator
                            LinearProgressIndicator(
                              value: currentExercise['sets'] != null
                                  ? _currentSet /
                                      (currentExercise['sets'] as int)
                                  : 0.5,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Exercise list
                      const Text(
                        'All Exercises',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_exercises.length, (index) {
                        final exercise = _exercises[index];
                        final isCurrent = index == _currentExerciseIndex;
                        final isCompleted = index < _currentExerciseIndex;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.primary
                                    .withAlpha((0.2 * 255).round())
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: isCompleted
                                ? const Icon(LucideIcons.checkCircle,
                                    color: AppColors.success)
                                : isCurrent
                                    ? const Icon(LucideIcons.playCircle,
                                        color: AppColors.primary)
                                    : const Icon(LucideIcons.circle,
                                        color: Colors.grey),
                            title: Text(
                              exercise['name'] as String? ?? 'Exercise',
                              style: TextStyle(
                                color: isCompleted ? Colors.grey : Colors.white,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              exercise['reps'] != null
                                  ? '${exercise['sets']} sets × ${exercise['reps']} reps'
                                  : exercise['duration_sec'] != null
                                      ? '${(exercise['duration_sec'] as int) ~/ 60} min'
                                      : 'N/A',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Control Buttons
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (!_isRunning && !_isPaused)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                  if (_isPaused)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resumeTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.play, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Resume',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isRunning)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pauseTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.pause, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pause',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isRunning || _isPaused) ...[
                    const SizedBox(width: 12),
                    if (currentExercise != null &&
                        currentExercise['reps'] != null &&
                        !_restMode)
                      ElevatedButton(
                        onPressed: _completeSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(LucideIcons.check, size: 24),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

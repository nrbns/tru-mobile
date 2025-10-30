import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/providers/today_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
// Removed unused import: today_service is provided via today_provider.
import '../../core/utils/lucide_compat.dart';

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? exercises;
  final String? workoutName;

  const WorkoutPlayerScreen({super.key, this.exercises, this.workoutName});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() =>
      _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _plan;
  int _index = 0;
  int _secondsLeft = 0;
  bool _isRest = false;
  Timer? _timer;
  final FlutterTts _tts = FlutterTts();
  // session id removed (not used).
  final DateTime _startedAt = DateTime.now();

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Ensure we have a mutable copy of the plan maps — callers may pass
    // const maps (or _defaultPlan returned const maps), which are
    // unmodifiable and will throw when edited. Create writable copies.
    final source = widget.exercises ?? _defaultPlan();
    _plan = source.map((m) => Map<String, dynamic>.from(m)).toList();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
    _startExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _defaultPlan() {
    return const [
      {
        'name': 'Jumping Jacks',
        'durationSec': 30,
        'restSec': 15,
        'emoji': '🤸'
      },
      {'name': 'Push Ups', 'durationSec': 30, 'restSec': 20, 'emoji': '💪'},
      {
        'name': 'Bodyweight Squats',
        'durationSec': 40,
        'restSec': 20,
        'emoji': '🏋️'
      },
      {'name': 'Plank', 'durationSec': 45, 'restSec': 30, 'emoji': '🧱'},
    ];
  }

  void _startExercise() {
    final current = _plan[_index];
    setState(() {
      _isRest = false;
      _secondsLeft = (current['durationSec'] as int?) ?? 30;
    });
    _speakCountdown(starting: _secondsLeft);
    _startTicker(onComplete: _startRest);
  }

  void _startRest() {
    final current = _plan[_index];
    setState(() {
      _isRest = true;
      _secondsLeft = (current['restSec'] as int?) ?? 20;
    });
    _beep();
    _speak('Rest');
    _startTicker(onComplete: _nextExercise);
  }

  void _nextExercise() async {
    if (_index < _plan.length - 1) {
      setState(() => _index++);
      _startExercise();
    } else {
      await _completeWorkout();
      if (mounted) context.pop();
    }
  }

  void _startTicker({required VoidCallback onComplete}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        onComplete();
      } else {
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 3 && _secondsLeft > 0) {
          _beep();
          _speak('$_secondsLeft');
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  Future<void> _completeWorkout() async {
    try {
      // Save session summary
      final elapsed = DateTime.now().difference(_startedAt).inSeconds;
      final todayService = ref.read(todayServiceProvider);
      final today = await todayService.getToday();
      await todayService.updateWorkoutStatus(
        done: today.workouts.done + 1,
        target: today.workouts.target,
      );
      // Optional: estimate calories as 6 METs average * time ~ simple estimate (kcal/min ~ 6)
      // Persist simple history entry without new dependencies
      // ignore: unused_local_variable
      final estimatedCalories = (elapsed / 60 * 6 * 5).round();
    } catch (_) {}
  }

  Future<void> _speakCountdown({required int starting}) async {
    if (starting <= 5) {
      for (int i = starting; i >= 1; i--) {
        // Let ticker drive the actual timing; this is a hint speech
        if (i <= 3) await _speak('$i');
      }
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (_) {}
  }

  void _beep() {
    SystemSound.play(SystemSoundType.click);
  }

  @override
  Widget build(BuildContext context) {
    final current = _plan[_index];
    // final isLast not used; removed to satisfy analyzer.
    final total = (_isRest
            ? (current['restSec'] as int? ?? 20)
            : (current['durationSec'] as int? ?? 30))
        .toDouble();
    final progress = 1 - (_secondsLeft / total);

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
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.workoutName ?? 'Workout',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _isRest
                              ? 'Rest'
                              : 'Exercise ${_index + 1}/${_plan.length}',
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.maximize, color: Colors.white),
                    onPressed: () async {
                      await SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersiveSticky);
                      await SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                    tooltip: 'Fullscreen',
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.minimize, color: Colors.white),
                    onPressed: () async {
                      await SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge);
                      await SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]);
                    },
                    tooltip: 'Exit Fullscreen',
                  ),
                  Text('$_secondsLeft s',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Animated exercise emoji
            ScaleTransition(
              scale: _pulseController,
              child: Text(
                (_isRest ? '🫗' : (current['emoji'] as String? ?? '🏋️')),
                style: const TextStyle(fontSize: 96),
              ),
            ),
            const SizedBox(height: 16),
            // Exercise name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _isRest ? 'Rest' : (current['name'] as String? ?? 'Exercise'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const Spacer(),
            // Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _index == 0 && !_isRest
                        ? null
                        : () {
                            _timer?.cancel();
                            if (_isRest) {
                              // skip rest
                              _nextExercise();
                            } else {
                              // go to previous exercise rest
                              setState(() {
                                _index =
                                    (_index - 1).clamp(0, _plan.length - 1);
                              });
                              _startExercise();
                            }
                          },
                    icon: const Icon(LucideIcons.skipBack),
                    label: const Text('Prev'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_timer == null) return;
                      if (_timer!.isActive) {
                        _timer!.cancel();
                      } else {
                        _startTicker(
                            onComplete: _isRest ? _nextExercise : _startRest);
                      }
                      setState(() {});
                    },
                    icon: Icon((_timer?.isActive ?? false)
                        ? LucideIcons.pause
                        : LucideIcons.play),
                    label:
                        Text((_timer?.isActive ?? false) ? 'Pause' : 'Resume'),
                  ),
                  // Edit timers
                  ElevatedButton.icon(
                    onPressed: () => _editTimers(current),
                    icon: const Icon(LucideIcons.sliders),
                    label: const Text('Edit'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _timer?.cancel();
                      if (_isRest) {
                        _nextExercise();
                      } else {
                        _startRest();
                      }
                    },
                    icon: Icon(_isRest
                        ? LucideIcons.skipForward
                        : LucideIcons.chevronRight),
                    label: Text(_isRest ? 'Next' : 'Skip'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editTimers(Map<String, dynamic> current) async {
    final exerciseCtrl =
        TextEditingController(text: '${current['durationSec'] ?? 30}');
    final restCtrl = TextEditingController(text: '${current['restSec'] ?? 20}');
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Timers',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _numberField('Exercise (sec)', exerciseCtrl),
              const SizedBox(height: 8),
              _numberField('Rest (sec)', restCtrl),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final ex = int.tryParse(exerciseCtrl.text) ?? 30;
                    final rs = int.tryParse(restCtrl.text) ?? 20;
                    setState(() {
                      current['durationSec'] = ex;
                      current['restSec'] = rs;
                      _secondsLeft = _isRest ? rs : ex;
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Apply'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _numberField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

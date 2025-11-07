import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/backend_providers.dart';
import '../../data/models/exercise_models.dart';
import '../../data/models/workout_models.dart';
import 'ar_workout_detector.dart';
import '../../core/services/realtime_workout_service.dart';
import '../../core/services/supabase_service.dart';

class ExerciseARScreen extends ConsumerStatefulWidget {
  const ExerciseARScreen({
    super.key,
    required this.exercise,
    required this.workoutExercise,
  });
  final Exercise exercise;
  final WorkoutExercise workoutExercise;

  @override
  ConsumerState<ExerciseARScreen> createState() => _ExerciseARScreenState();
}

class _ExerciseARScreenState extends ConsumerState<ExerciseARScreen> {
  bool _isRecording = false;
  int _currentRep = 0;
  int _currentSet = 1;
  List<RepMetric> _repMetrics = [];
  List<String> _currentErrors = [];
  double _formScore = 100.0;

  @override
  void initState() {
    super.initState();
    // If the workoutExercise has a session id attached (some flows may set
    // this), subscribe to live backend updates. Otherwise we'll create a
    // session lazily when recording starts.
    _subscribeIfHasSession();
  }

  String? _sessionId;
  StreamSubscription<Map<String, dynamic>>? _sessionSub;

  void _subscribeIfHasSession() {
    try {
      final json = widget.workoutExercise.toJson();
      final maybe = json['session_id'];
      if (maybe is String && maybe.isNotEmpty) {
        _sessionId = maybe;
        _sessionSub = RealtimeWorkoutService.instance
            .subscribeToSession(_sessionId!)
            .listen((update) {
          if (update.isNotEmpty) {
            setState(() {
              _currentRep = (update['current_rep'] as int?) ?? _currentRep;
              _formScore =
                  ((update['last_form_score'] ?? _formScore) as num).toDouble();
              final lastErrors = update['last_errors'];
              if (lastErrors is List) {
                _currentErrors =
                    List<String>.from(lastErrors.map((e) => e.toString()));
              }
            });
          }
        }, onError: (e) {
          debugPrint('session subscription error: $e');
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showExerciseInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // AR Camera View (Real)
          Expanded(
            child: ARWorkoutDetector(
              exercise: widget.exercise,
              workoutExercise: widget.workoutExercise,
              onRepDetected: _handleRepDetected,
              onFormErrorsDetected: _handleFormErrorsDetected,
              onFormScoreUpdated: _handleFormScoreUpdated,
            ),
          ),

          // Exercise Info
          _buildExerciseInfo(),

          // Rep Counter and Controls
          _buildRepControls(),

          // Form Analysis
          _buildFormAnalysis(),

          // Set Progress
          _buildSetProgress(),
        ],
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  // ignore: unused_element
  Widget _buildARCameraView() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Stack(
        children: [
          // Simulated camera view
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 64,
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording ? 'Recording...' : 'AR Camera View',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isRecording) ...[
                  const SizedBox(height: 8),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ],
            ),
          ),

          // AR Overlays
          if (_isRecording) _buildAROverlays(),
        ],
      ),
    );
  }

  Widget _buildAROverlays() {
    return Stack(
      children: [
        // Form analysis indicators
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Score: ${_formScore.toInt()}%',
                  style: TextStyle(
                    color: _formScore >= 80
                        ? Colors.green
                        : _formScore >= 60
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentErrors.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Errors: ${_currentErrors.length}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Rep counter
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_currentRep',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Exercise cues
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.exercise.cuesString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set $_currentSet of ${widget.workoutExercise.sets}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.workoutExercise.reps} reps',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Primary: ${widget.exercise.primaryMuscle}',
            style: const TextStyle(color: Colors.grey),
          ),
          if (widget.exercise.equipment.isNotEmpty)
            Text(
              'Equipment: ${widget.exercise.equipmentString}',
              style: const TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildRepControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
            label: Text(_isRecording ? 'Stop' : 'Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _completeRep,
            icon: const Icon(Icons.check),
            label: const Text('Complete Rep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormAnalysis() {
    if (!_isRecording) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Real-time Form Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _formScore / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _formScore >= 80
                  ? Colors.green
                  : _formScore >= 60
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Form Score: ${_formScore.toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _formScore >= 80
                  ? Colors.green
                  : _formScore >= 60
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          if (_currentErrors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _currentErrors
                  .map((error) => Chip(
                        label: Text(error),
                        backgroundColor:
                            Colors.red.withAlpha((0.1 * 255).round()),
                        labelStyle:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetProgress() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Set Progress'),
              Text('$_currentRep / ${widget.workoutExercise.reps}'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentRep / widget.workoutExercise.reps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _skipSet,
              child: const Text('Skip Set'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _completeSet,
              child: const Text('Complete Set'),
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _currentRep = 0;
      _repMetrics = [];
      _currentErrors = [];
      _formScore = 100.0;
    });

    // Simulate AR analysis
    _simulateARAnalysis();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _completeRep() async {
    if (!_isRecording) return;

    setState(() {
      _currentRep++;

      // Create rep metric
      final repMetric = RepMetric(
        repNumber: _currentRep,
        timestamp: DateTime.now(),
        metrics: {
          'form_score': _formScore,
          'errors': _currentErrors,
          'duration': 3.0, // Simulated rep duration
        },
        quality: _formScore / 100,
        errors: _currentErrors,
      );

      _repMetrics.add(repMetric);

      // Reset for next rep
      _currentErrors = [];
      _formScore = 100.0;
    });

    // Simulate next rep analysis
    if (_currentRep < widget.workoutExercise.reps) {
      _simulateARAnalysis();
    }

    // Ensure we have a live session id: create one lazily if needed.
    if (_sessionId == null) {
      try {
        final userId = SupabaseService.instance.currentUser?.id;
        final created = await RealtimeWorkoutService.instance
            .createSession(userId: userId, exerciseName: widget.exercise.name);
        if (created != null) {
          _sessionId = created;
          // subscribe to session updates
          _sessionSub?.cancel();
          _sessionSub = RealtimeWorkoutService.instance
              .subscribeToSession(_sessionId!)
              .listen((update) {
            if (update.isNotEmpty) {
              setState(() {
                _currentRep = (update['current_rep'] as int?) ?? _currentRep;
                _formScore = ((update['last_form_score'] ?? _formScore) as num)
                    .toDouble();
                final lastErrors = update['last_errors'];
                if (lastErrors is List) {
                  _currentErrors =
                      List<String>.from(lastErrors.map((e) => e.toString()));
                }
              });
            }
          }, onError: (e) {
            debugPrint('session subscription error: $e');
          });
        }
      } catch (e) {
        debugPrint('create session failed: $e');
      }
    }

    // Push rep data to backend (best-effort). Fire-and-forget so UI isn't blocked.
    if (_sessionId != null) {
      // ignore: unawaited_futures
      RealtimeWorkoutService.instance.pushRepData(
        sessionId: _sessionId!,
        repNo: _currentRep,
        formScore: _formScore,
        errors: _repMetrics.last.errors ?? [],
      );
    }
  }

  void _simulateARAnalysis() {
    // Simulate AR analysis with random form issues
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isRecording) return;

      setState(() {
        // Simulate random form errors
        final possibleErrors = [
          'Depth too shallow',
          'Knee valgus',
          'Hip shift',
          'Too fast tempo',
          'Short ROM',
        ];

        _currentErrors = possibleErrors
            .where((error) => (DateTime.now().millisecond % 3) == 0)
            .toList();

        // Calculate form score based on errors
        _formScore =
            (100 - (_currentErrors.length * 15)).clamp(0.0, 100.0).toDouble();
      });
    });
  }

  void _skipSet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Set'),
        content: const Text('Are you sure you want to skip this set?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToNextSet();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _completeSet() {
    if (_currentRep < widget.workoutExercise.reps) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Set'),
          content: Text(
              'You\'ve only completed $_currentRep out of ${widget.workoutExercise.reps} reps. Complete the set?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _finishSet();
              },
              child: const Text('Finish Set'),
            ),
          ],
        ),
      );
    } else {
      _finishSet();
    }
  }

  void _finishSet() {
    // Create set log
    final setLog = SetLog(
      id: DateTime.now().millisecondsSinceEpoch,
      workoutId: 1, // This would come from the workout context
      exerciseId: widget.exercise.id,
      setNo: _currentSet,
      reps: _currentRep,
      repMetrics: _repMetrics,
      arScores: {
        'overall_score': _calculateOverallScore(),
        'errors': _getErrorCounts(),
        'average_form_score': _calculateAverageFormScore(),
      },
      painFlag: false,
    );

    // Add to workout session
    ref.read(workoutSessionProvider.notifier).addSetLog(setLog);

    // Mark set completed in backend if we have a session id.
    if (_sessionId != null) {
      // ignore: unawaited_futures
      RealtimeWorkoutService.instance
          .updateSetStatus(_sessionId!, _currentSet, true);
    }
    _goToNextSet();
  }

  void _goToNextSet() {
    if (_currentSet < widget.workoutExercise.sets) {
      setState(() {
        _currentSet++;
        _currentRep = 0;
        _repMetrics = [];
        _currentErrors = [];
        _formScore = 100.0;
        _isRecording = false;
      });
    } else {
      // All sets completed
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise completed! Great job!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  double _calculateOverallScore() {
    if (_repMetrics.isEmpty) return 0.0;
    return _repMetrics.map((m) => m.quality ?? 0.0).reduce((a, b) => a + b) /
        _repMetrics.length;
  }

  Map<String, int> _getErrorCounts() {
    final errorCounts = <String, int>{};
    for (final metric in _repMetrics) {
      for (final error in metric.errors ?? []) {
        errorCounts[error] = (errorCounts[error] ?? 0) + 1;
      }
    }
    return errorCounts;
  }

  double _calculateAverageFormScore() {
    if (_repMetrics.isEmpty) return 0.0;
    return _repMetrics.map((m) => m.quality ?? 0.0).reduce((a, b) => a + b) /
        _repMetrics.length;
  }

  void _showExerciseInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.exercise.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Primary Muscle: ${widget.exercise.primaryMuscle}'),
            Text(
                'Secondary Muscles: ${widget.exercise.secondaryMuscles.join(', ')}'),
            Text('Equipment: ${widget.exercise.equipmentString}'),
            const SizedBox(height: 16),
            const Text('Form Cues:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.exercise.cues.map((cue) => Text('• $cue')),
            const SizedBox(height: 16),
            const Text('AR Error Rules:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.exercise.arErrRules.entries.map((entry) {
              final rule = ARErrorRule.fromJson(entry.value);
              return Text('• ${rule.conditionDescription}');
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleRepDetected(RepMetric repMetric) {
    setState(() {
      _currentRep = repMetric.repNumber;
      _repMetrics.add(repMetric);
    });

    // Show rep completion feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rep ${repMetric.repNumber} completed!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleFormErrorsDetected(List<String> errors) {
    setState(() {
      _currentErrors = errors;
    });
  }

  void _handleFormScoreUpdated(double score) {
    setState(() {
      _formScore = score;
    });
  }
}

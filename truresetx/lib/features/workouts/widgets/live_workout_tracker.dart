import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../data/providers/live_data_providers.dart';
import '../../../core/services/realtime_service.dart';

class LiveWorkoutTracker extends ConsumerStatefulWidget {
  const LiveWorkoutTracker({
    super.key,
    required this.workoutId,
    required this.workoutName,
    required this.duration,
  });
  final String workoutId;
  final String workoutName;
  final int duration;

  @override
  ConsumerState<LiveWorkoutTracker> createState() => _LiveWorkoutTrackerState();
}

class _LiveWorkoutTrackerState extends ConsumerState<LiveWorkoutTracker> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _heartRate = 0;
  int _caloriesBurned = 0;
  int _repsCompleted = 0;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLiveTracking() {
    setState(() {
      _isTracking = true;
    });

    // Start timer for workout duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });

      // Send live metrics every 10 seconds
      if (_elapsedSeconds % 10 == 0) {
        _sendLiveMetrics();
      }
    });

    // Simulate heart rate changes
    _simulateHeartRate();
  }

  void _simulateHeartRate() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      setState(() {
        // Simulate heart rate between 120-160 BPM during workout
        _heartRate = 120 + (DateTime.now().millisecond % 40);
        _caloriesBurned = (_elapsedSeconds * 0.1).round();
        _repsCompleted = (_elapsedSeconds / 3).round();
      });
    });
  }

  void _sendLiveMetrics() {
    final realtimeService = ref.read(realtimeServiceProvider);
    realtimeService.sendWorkoutMetrics(widget.workoutId, {
      'elapsed_seconds': _elapsedSeconds,
      'heart_rate': _heartRate,
      'calories_burned': _caloriesBurned,
      'reps_completed': _repsCompleted,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    _timer?.cancel();
    _sendLiveMetrics(); // Send final metrics
  }

  @override
  Widget build(BuildContext context) {
    final liveMetrics = ref.watch(liveWorkoutMetricsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withAlpha((0.1 * 255).round()),
            Colors.purple.withAlpha((0.1 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isTracking ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isTracking ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workoutName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isTracking ? 'Live Tracking Active' : 'Workout Complete',
                      style: TextStyle(
                        color: _isTracking ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isTracking)
                IconButton(
                  onPressed: _stopTracking,
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Live Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Time',
                  _formatTime(_elapsedSeconds),
                  Icons.timer,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Heart Rate',
                  '$_heartRate BPM',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Calories',
                  '$_caloriesBurned',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Reps',
                  '$_repsCompleted',
                  Icons.repeat,
                  Colors.green,
                ),
              ),
            ],
          ),

          // Live Data Stream
          const SizedBox(height: 20),
          liveMetrics.when(
            data: (metrics) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Live Data Stream',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Last update: ${DateTime.now().toString().substring(11, 19)}'),
                  if (metrics.isNotEmpty) ...[
                    Text('External metrics: ${metrics.length} received'),
                  ],
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withAlpha((0.8 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

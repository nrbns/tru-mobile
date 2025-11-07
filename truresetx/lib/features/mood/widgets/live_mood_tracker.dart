import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/live_data_providers.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/supabase_service.dart';

class LiveMoodTracker extends ConsumerStatefulWidget {
  const LiveMoodTracker({super.key});

  @override
  ConsumerState<LiveMoodTracker> createState() => _LiveMoodTrackerState();
}

class _LiveMoodTrackerState extends ConsumerState<LiveMoodTracker> {
  int _currentMood = 5;
  int _currentEnergy = 5;
  int _currentStress = 5;
  // connection indicator
  bool _connected = false;
  StreamSubscription<String>? _connSub;

  @override
  Widget build(BuildContext context) {
    final moodLogs = ref.watch(liveMoodLogsProvider);
    final liveMetrics = ref.watch(liveMoodTrackingProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withAlpha((0.1 * 255).round()),
            Colors.pink.withAlpha((0.1 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withAlpha((0.3 * 255).round())),
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
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Live Mood Tracking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // live dot
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _connected ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Real-time emotional wellness',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Mood Sliders
          _buildMoodSlider('Mood', _currentMood, (value) {
            setState(() {
              _currentMood = value.round();
            });
            _sendMoodUpdate();
          }, Colors.blue),
          const SizedBox(height: 16),
          _buildMoodSlider('Energy', _currentEnergy, (value) {
            setState(() {
              _currentEnergy = value.round();
            });
            _sendMoodUpdate();
          }, Colors.orange),
          const SizedBox(height: 16),
          _buildMoodSlider('Stress', _currentStress, (value) {
            setState(() {
              _currentStress = value.round();
            });
            _sendMoodUpdate();
          }, Colors.red),
          const SizedBox(height: 20),

          // Mood History
          moodLogs.when(
            data: (logs) => _buildMoodHistory(logs),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),

          const SizedBox(height: 20),

          // Live Data Stream
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
                        'Live Mood Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Last update: ${DateTime.now().toString().substring(11, 19)}'),
                  if (metrics.isNotEmpty) ...[
                    Text('Live updates: ${metrics.length} received'),
                  ],
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Delay until after mount to access ref
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = ref.read(realtimeServiceProvider);
      final supabase = ref.read(supabaseClientProvider);

      try {
        // initialize realtime service with supabase client
        await service.initialize(supabase);

        // subscribe to user-specific channel if authenticated
        final user = supabase.auth.currentUser;
        if (user != null) {
          await service.subscribeToUser(user.id);
        }

        // watch connection status provider and show live-dot. Use ref.listen
        // instead of accessing the underlying .stream (deprecated).
        ref.listen(realtimeConnectionProvider, (previous, next) {
          final s = next.asData?.value ?? '';
          final connected = s.toLowerCase().contains('connected');
          if (mounted) {
            setState(() => _connected = connected);
          }
        });
      } catch (_) {
        // ignore initialization errors for now
      }
    });
  }

  @override
  void dispose() {
    try {
      final service = ref.read(realtimeServiceProvider);
      service.unsubscribe();
    } catch (_) {}
    _connSub?.cancel();
    super.dispose();
  }

  Widget _buildMoodSlider(
      String label, int value, ValueChanged<double> onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$value/10',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withAlpha((0.2 * 255).round()),
            thumbColor: color,
            overlayColor: color.withAlpha((0.2 * 255).round()),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodHistory(List<dynamic> logs) {
    if (logs.isEmpty) {
      return const Text('No mood data yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Mood Logs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...logs.take(3).map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getMoodIcon(log.moodScore ?? 5),
                    color: _getMoodColor(log.moodScore ?? 5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Mood: ${log.moodScore ?? 5}/10'),
                  const Spacer(),
                  Text(
                    _formatDate(log.createdAt ?? DateTime.now()),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  IconData _getMoodIcon(int mood) {
    if (mood >= 8) return Icons.sentiment_very_satisfied;
    if (mood >= 6) return Icons.sentiment_satisfied;
    if (mood >= 4) return Icons.sentiment_neutral;
    if (mood >= 2) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  Color _getMoodColor(int mood) {
    if (mood >= 8) return Colors.green;
    if (mood >= 6) return Colors.lightGreen;
    if (mood >= 4) return Colors.orange;
    if (mood >= 2) return Colors.red;
    return Colors.deepOrange;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _sendMoodUpdate() {
    final realtimeService = ref.read(realtimeServiceProvider);
    realtimeService.sendMoodUpdate({
      'mood': _currentMood,
      'energy': _currentEnergy,
      'stress': _currentStress,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

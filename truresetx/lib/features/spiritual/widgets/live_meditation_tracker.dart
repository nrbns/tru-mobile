import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../data/providers/live_data_providers.dart';
import '../../../core/services/realtime_service.dart';

class LiveMeditationTracker extends ConsumerStatefulWidget {
  const LiveMeditationTracker({super.key});

  @override
  ConsumerState<LiveMeditationTracker> createState() =>
      _LiveMeditationTrackerState();
}

class _LiveMeditationTrackerState extends ConsumerState<LiveMeditationTracker> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isMeditating = false;
  String _selectedType = 'mindfulness';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMeditation() {
    setState(() {
      _isMeditating = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });

      // Send live progress every 30 seconds
      if (_elapsedSeconds % 30 == 0) {
        _sendMeditationProgress();
      }
    });

    _sendMeditationProgress();
  }

  void _stopMeditation() {
    setState(() {
      _isMeditating = false;
    });
    _timer?.cancel();
    _sendMeditationProgress(); // Send final progress
  }

  void _sendMeditationProgress() {
    final realtimeService = ref.read(realtimeServiceProvider);
    realtimeService.sendMeditationProgress(
        'meditation-${DateTime.now().millisecondsSinceEpoch}', {
      'type': _selectedType,
      'elapsed_seconds': _elapsedSeconds,
      'is_active': _isMeditating,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final meditationLogs = ref.watch(liveMeditationLogsProvider);
    final liveMetrics = ref.watch(liveMeditationProgressProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withAlpha((0.1 * 255).round()),
            Colors.purple.withAlpha((0.1 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withAlpha((0.3 * 255).round())),
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
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.spa,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Meditation Tracker',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Real-time mindfulness tracking',
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

          // Meditation Type Selector
          if (!_isMeditating) ...[
            const Text(
              'Select Meditation Type',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip('mindfulness', 'Mindfulness'),
                _buildTypeChip('breathwork', 'Breathwork'),
                _buildTypeChip('loving_kindness', 'Loving Kindness'),
                _buildTypeChip('body_scan', 'Body Scan'),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Timer Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isMeditating
                  ? Colors.orange.withAlpha((0.1 * 255).round())
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isMeditating ? Colors.orange : Colors.grey[300]!,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(_elapsedSeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _isMeditating ? Colors.orange : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isMeditating ? 'Meditating...' : 'Ready to begin',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isMeditating ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isMeditating ? _stopMeditation : _startMeditation,
                  icon: Icon(_isMeditating ? Icons.stop : Icons.play_arrow),
                  label: Text(_isMeditating ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMeditating ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Meditation History
          meditationLogs.when(
            data: (logs) => _buildMeditationHistory(logs),
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
                        'Live Meditation Data',
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

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
      selectedColor: Colors.orange.withAlpha((0.2 * 255).round()),
      checkmarkColor: Colors.orange,
    );
  }

  Widget _buildMeditationHistory(List<dynamic> logs) {
    if (logs.isEmpty) {
      return const Text('No meditation sessions yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sessions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...logs.take(3).map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.spa,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                      '${log.type ?? 'Meditation'}: ${_formatTime(log.duration ?? 0)}'),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
}

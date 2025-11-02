import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MeditationTrackerScreen extends StatefulWidget {
  const MeditationTrackerScreen({super.key});

  @override
  State<MeditationTrackerScreen> createState() =>
      _MeditationTrackerScreenState();
}

class _MeditationTrackerScreenState extends State<MeditationTrackerScreen> {
  bool _running = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void _start() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    setState(() => _running = true);
  }

  void _stop() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() => _running = false);
    // TODO: persist session to Firestore via provider when implemented
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Meditation Tracker'),
          backgroundColor: AppColors.surface),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_running ? 'Meditating...' : 'Ready',
                style: const TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 16),
            Text(
                '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white, fontSize: 48)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _running ? _stop : _start,
              child: Text(_running ? 'Stop' : 'Start'),
            )
          ],
        ),
      ),
    );
  }
}

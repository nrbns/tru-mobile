// ignore_for_file: use_super_parameters
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/life_event_detector.dart';
import '../../core/services/emotional_twin.dart';
import '../../core/services/resilience_calculator.dart';
import '../../core/services/ai_orchestrator_stub.dart';

class LifeOSOverview extends ConsumerStatefulWidget {
  final String userId;
  const LifeOSOverview({super.key, required this.userId});

  @override
  ConsumerState<LifeOSOverview> createState() => _LifeOSOverviewState();
}

class _LifeOSOverviewState extends ConsumerState<LifeOSOverview> {
  final _detector = LifeEventDetector();
  final _twin = EmotionalTwin();
  final _calc = ResilienceCalculator();
  final _orchestrator = AIOrchestrator();

  int _score = 50;
  List<String> _events = [];

  void _runDetection() async {
    // Demo snapshot — in a real app we would compute these from streams & server aggregates
    final snapshot = <String, dynamic>{
      'avg_sleep_hours': 4.5,
      'mood_avg': 3.2,
      'recent_spend_change_percent': 60.0,
      'event_flags': <String>['breakup']
    };
    final events = _detector.detectFromSnapshot(snapshot);
    setState(() => _events = events);
    await _orchestrator.handleDetectedEvents(widget.userId, events);
    _twin.updateFromMoodLogs([3, 4, 3, 2, 4, 3]);
    final prob = _twin.predictMeltdownProbability();
    final tone = _twin.voiceTonePreference();
    final score = _calc.computeScore(
        moodAvg: 3.2,
        sleepMin: 360,
        financialStress: 0.6,
        activityMin: 20,
        socialScore: 0.4);
    setState(() {
      _score = score;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Detection done — meltdown p=${(prob * 100).round()}% • tone=$tone')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Life OS Overview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Resilience Score'),
                trailing: Text('$_score / 100',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text('Morning summary & quick actions'),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
                onPressed: _runDetection,
                child: Text('Run Life Event Detection & AI')),
            SizedBox(height: 12),
            if (_events.isNotEmpty) ...[
              Text('Detected events:',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final e in _events) ListTile(title: Text(e)),
            ] else
              Text('No events detected yet.'),
            SizedBox(height: 12),
            Expanded(
                child: Center(
                    child: Text(
                        'Emotional Twin preview & adaptive modes coming soon',
                        textAlign: TextAlign.center))),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/agent_providers.dart';
import '../../core/services/spiritual_fitness_service.dart';

/// Spiritual Fitness Screen - Workout with mantras/guidance
class SpiritualFitnessScreen extends ConsumerStatefulWidget {
  const SpiritualFitnessScreen({super.key});

  @override
  ConsumerState<SpiritualFitnessScreen> createState() => _SpiritualFitnessScreenState();
}

class _SpiritualFitnessScreenState extends ConsumerState<SpiritualFitnessScreen> {
  String _selectedWorkout = 'yoga';
  int _duration = 30;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(spiritualFitnessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Fitness'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Combine Movement with Spiritual Practice',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWorkout,
                      items: const [
                        DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
                        DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                        DropdownMenuItem(value: 'strength', child: Text('Strength')),
                        DropdownMenuItem(value: 'walking', child: Text('Walking')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedWorkout = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Duration (minutes)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _duration.toDouble(),
                      min: 10,
                      max: 60,
                      divisions: 10,
                      label: '$_duration minutes',
                      onChanged: (value) {
                        setState(() => _duration = value.round());
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        final routine = await service.generateRoutine(
                          workoutType: _selectedWorkout,
                          duration: _duration,
                        );

                        if (mounted) {
                          final navContext = context;
                          Navigator.of(navContext).push(
                            MaterialPageRoute(
                              builder: (_) => SpiritualFitnessPlayerScreen(routine: routine),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Start Spiritual Fitness'),
                    ),
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

class SpiritualFitnessPlayerScreen extends StatelessWidget {
  final SpiritualFitnessRoutine routine;

  const SpiritualFitnessPlayerScreen({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${routine.workoutType.toUpperCase()} + ${routine.philosophy.name.toUpperCase()}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      routine.mantra,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Repeat throughout your practice',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Segments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...routine.segments.map((segment) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${segment.segmentNumber}'),
                    ),
                    title: Text(segment.instruction),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(segment.spiritualGuidance),
                        const SizedBox(height: 8),
                        Text(
                          '${segment.duration} minutes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}


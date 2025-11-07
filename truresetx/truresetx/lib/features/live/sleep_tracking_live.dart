// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/in_memory_health_repo.dart';

final sleepStreamProvider =
    StreamProvider.family<List<SleepSession>, String>((ref, userId) {
  final repo = InMemoryHealthRepository.instance;
  return repo.streamSleepSessions(userId);
});

class SleepTrackingLive extends ConsumerStatefulWidget {
  final String userId;
  const SleepTrackingLive({super.key, required this.userId});

  @override
  ConsumerState<SleepTrackingLive> createState() => _SleepTrackingLiveState();
}

class _SleepTrackingLiveState extends ConsumerState<SleepTrackingLive> {
  @override
  Widget build(BuildContext context) {
    final sleepAsync = ref.watch(sleepStreamProvider(widget.userId));

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final repo = InMemoryHealthRepository.instance;
            final now = DateTime.now();
            await repo.addSleep(
                widget.userId,
                SleepSession(
                    startAt: now.subtract(Duration(hours: 7, minutes: 30)),
                    endAt: now,
                    efficiency: 85));
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sleep session added (demo)')));
          },
          child: Text('Add demo sleep session'),
        ),
        Expanded(
          child: sleepAsync.when(
            data: (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final s = list[list.length - 1 - i];
                return ListTile(
                  title: Text('Sleep ${s.startAt} → ${s.endAt}'),
                  subtitle: Text('Efficiency: ${s.efficiency}%'),
                );
              },
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, st) =>
                Center(child: Text('Error loading sleep sessions')),
          ),
        ),
      ],
    );
  }
}

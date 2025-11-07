// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/in_memory_health_repo.dart';

final _repoProvider = Provider((ref) => InMemoryHealthRepository.instance);

final moodStreamProvider =
    StreamProvider.family<List<MoodLog>, String>((ref, userId) {
  final repo = ref.watch(_repoProvider);
  return repo.streamMoodLogs(userId);
});

class MoodTrackingLive extends ConsumerStatefulWidget {
  final String userId;
  const MoodTrackingLive({super.key, required this.userId});

  @override
  ConsumerState<MoodTrackingLive> createState() => _MoodTrackingLiveState();
}

class _MoodTrackingLiveState extends ConsumerState<MoodTrackingLive> {
  int _mood = 6;
  int _energy = 6;
  final _noteC = TextEditingController();

  @override
  void dispose() {
    _noteC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodAsync = ref.watch(moodStreamProvider(widget.userId));

    return Column(
      children: [
        ListTile(
          title: Text('Mood'),
          subtitle: Text('$_mood / 10'),
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          value: _mood.toDouble(),
          onChanged: (v) => setState(() => _mood = v.toInt()),
        ),
        ListTile(
          title: Text('Energy'),
          subtitle: Text('$_energy / 10'),
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          value: _energy.toDouble(),
          onChanged: (v) => setState(() => _energy = v.toInt()),
        ),
        TextField(
            controller: _noteC,
            decoration: InputDecoration(labelText: 'Note (optional)')),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(_repoProvider);
                await repo.addMood(
                    widget.userId,
                    MoodLog(
                        recordedAt: DateTime.now(),
                        mood: _mood,
                        energy: _energy,
                        note: _noteC.text.isEmpty ? null : _noteC.text));
                _noteC.clear();
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Mood logged')));
              },
              child: Text('Log Mood'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Expanded(
          child: moodAsync.when(
            data: (items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final m = items[items.length - 1 - i];
                return ListTile(
                  title: Text('Mood ${m.mood} • Energy ${m.energy}'),
                  subtitle: Text('${m.recordedAt.toLocal()} ${m.note ?? ''}'),
                );
              },
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading moods')),
          ),
        ),
      ],
    );
  }
}

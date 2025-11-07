import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/in_memory_mr_repo.dart';
import '../../core/models/mr_models.dart';
import 'im_breaking_button.dart';

class MRDashboard extends ConsumerWidget {
  final String userId;
  const MRDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = InMemoryMRRepository.instance;

    return Scaffold(
      appBar: AppBar(title: Text('Motivation & Resilience')),
      floatingActionButton: ImBreakingButton(userId: userId),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MREvent>>(
                stream: repo.streamEvents(userId),
                builder: (context, snap) {
                  final items = snap.data ?? [];
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                            title: Text('Recent Events (${items.length})')),
                        Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (c, i) {
                              final e = items[items.length - 1 - i];
                              return ListTile(
                                  title: Text(e.kind),
                                  subtitle: Text(
                                      'Intensity ${e.intensity} • ${e.recordedAt}'));
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<MRIncident>>(
                stream: repo.streamIncidents(userId),
                builder: (context, snap) {
                  final items = snap.data ?? [];
                  return Card(
                    child: Column(
                      children: [
                        ListTile(title: Text('Incidents (${items.length})')),
                        Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (c, i) {
                              final it = items[items.length - 1 - i];
                              return ListTile(
                                  title: Text(it.source),
                                  subtitle: Text(it.description ?? ''));
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously, unused_element_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/in_memory_mr_repo.dart';

class ImBreakingButton extends ConsumerWidget {
  final String userId;
  const ImBreakingButton({super.key, required this.userId});

  void _showSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _ImBreakingSheet(userId: userId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: Icon(Icons.bolt),
      label: Text("I'm Breaking"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
      onPressed: () => _showSheet(context, ref),
    );
  }
}

class _ImBreakingSheet extends ConsumerStatefulWidget {
  final String userId;
  const _ImBreakingSheet({super.key, required this.userId});

  @override
  ConsumerState<_ImBreakingSheet> createState() => _ImBreakingSheetState();
}

class _ImBreakingSheetState extends ConsumerState<_ImBreakingSheet> {
  String _selected = 'love_failure';
  int _intensity = 7;
  final _noteC = TextEditingController();

  @override
  void dispose() {
    _noteC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('I need help right now',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ChoiceChip(
                  label: Text('Love'),
                  selected: _selected == 'love_failure',
                  onSelected: (_) =>
                      setState(() => _selected = 'love_failure')),
              ChoiceChip(
                  label: Text('Debt'),
                  selected: _selected == 'debt_pressure',
                  onSelected: (_) =>
                      setState(() => _selected = 'debt_pressure')),
              ChoiceChip(
                  label: Text('Boss'),
                  selected: _selected == 'boss_harassment',
                  onSelected: (_) =>
                      setState(() => _selected = 'boss_harassment')),
              ChoiceChip(
                  label: Text('Anger'),
                  selected: _selected == 'anger_surge',
                  onSelected: (_) => setState(() => _selected = 'anger_surge')),
            ]),
            SizedBox(height: 12),
            Text('Intensity: $_intensity'),
            Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value: _intensity.toDouble(),
                onChanged: (v) => setState(() => _intensity = v.toInt())),
            TextField(
                controller: _noteC,
                decoration: InputDecoration(labelText: 'Optional note / tag')),
            SizedBox(height: 8),
            Row(children: [
              ElevatedButton(
                onPressed: () async {
                  final repo = InMemoryMRRepository.instance;
                  await repo.addEvent(widget.userId, _selected, _intensity,
                      note: _noteC.text.isEmpty ? null : _noteC.text);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Event logged; recommendations queued')));
                  Navigator.of(context).pop();
                },
                child: Text('Ground & Generate'),
              ),
              SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final repo = InMemoryMRRepository.instance;
                  // Incident (harassment shield) quick flow
                  await repo.addIncident(widget.userId, 'voice',
                      description: _noteC.text.isEmpty ? null : _noteC.text,
                      tags: ['manual']);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Incident recorded')));
                  Navigator.of(context).pop();
                },
                child: Text('Record Incident'),
              )
            ])
          ],
        ),
      ),
    );
  }
}

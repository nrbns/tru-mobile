import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truresetx/core/services/current_user_provider.dart';
import 'package:truresetx/core/data/metrics_repository.dart';

class WeightLoggerScreen extends ConsumerStatefulWidget {
  const WeightLoggerScreen({super.key});

  @override
  ConsumerState<WeightLoggerScreen> createState() => _WeightLoggerScreenState();
}

class _WeightLoggerScreenState extends ConsumerState<WeightLoggerScreen> {
  final _kgController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();

  @override
  void dispose() {
    _kgController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }

    final kg = double.tryParse(_kgController.text);
    final bodyFat = double.tryParse(_bodyFatController.text);
    final waist = int.tryParse(_waistController.text);

    if (kg == null) return;

    // call the family provider with the named-record shape the provider expects
    await ref.read(addWeightProvider(
        (userId: userId, kg: kg, bodyFat: bodyFat, waistCm: waist)).future);

    _kgController.clear();
    _bodyFatController.clear();
    _waistController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Weight logged')));
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Weight Logger')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kgController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
            TextField(
              controller: _bodyFatController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Body fat (%)'),
            ),
            TextField(
              controller: _waistController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Waist (cm)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submit, child: const Text('Log Weight')),
            const SizedBox(height: 16),
            if (userId != null) ...[
              const Text('Recent weights:'),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final async = ref.watch(metricsStreamProvider(userId));
                  return async.when(
                    data: (list) => ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, idx) {
                        final row = list[idx];
                        final kg = row['kg'] ?? '--';
                        final at =
                            row['recorded_at'] ?? row['created_at'] ?? '';
                        return ListTile(
                          title: Text('Weight: $kg kg'),
                          subtitle: Text('$at'),
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                  );
                }),
              )
            ] else ...[
              const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Text('Sign in to log weights.'),
              )
            ]
          ],
        ),
      ),
    );
  }
}

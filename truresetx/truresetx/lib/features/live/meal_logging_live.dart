// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/in_memory_health_repo.dart';

final mealStreamProvider =
    StreamProvider.family<List<MealLog>, String>((ref, userId) {
  final repo = InMemoryHealthRepository.instance;
  return repo.streamMealLogs(userId);
});

class MealLoggingLive extends ConsumerStatefulWidget {
  final String userId;
  const MealLoggingLive({super.key, required this.userId});

  @override
  ConsumerState<MealLoggingLive> createState() => _MealLoggingLiveState();
}

class _MealLoggingLiveState extends ConsumerState<MealLoggingLive> {
  final _descC = TextEditingController();
  final _carbsC = TextEditingController();
  final _proteinC = TextEditingController();
  final _fatC = TextEditingController();

  @override
  void dispose() {
    _descC.dispose();
    _carbsC.dispose();
    _proteinC.dispose();
    _fatC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealStreamProvider(widget.userId));

    return Column(
      children: [
        TextField(
            controller: _descC,
            decoration: InputDecoration(labelText: 'Meal description')),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _carbsC,
                  decoration: InputDecoration(labelText: 'Carbs g'))),
          Expanded(
              child: TextField(
                  controller: _proteinC,
                  decoration: InputDecoration(labelText: 'Protein g'))),
          Expanded(
              child: TextField(
                  controller: _fatC,
                  decoration: InputDecoration(labelText: 'Fat g')))
        ]),
        ElevatedButton(
          onPressed: () async {
            final repo = InMemoryHealthRepository.instance;
            final carbs = num.tryParse(_carbsC.text) ?? 0;
            final protein = num.tryParse(_proteinC.text) ?? 0;
            final fat = num.tryParse(_fatC.text) ?? 0;
            await repo.addMeal(
                widget.userId,
                MealLog(
                    recordedAt: DateTime.now(),
                    description: _descC.text,
                    carbs: carbs,
                    protein: protein,
                    fat: fat));
            _descC.clear();
            _carbsC.clear();
            _proteinC.clear();
            _fatC.clear();
            if (!mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Meal logged')));
          },
          child: Text('Log Meal'),
        ),
        Expanded(
          child: mealsAsync.when(
            data: (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final m = list[list.length - 1 - i];
                return ListTile(
                    title: Text(m.description),
                    subtitle:
                        Text('Carbs ${m.carbs}g • Protein ${m.protein}g'));
              },
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading meals')),
          ),
        ),
      ],
    );
  }
}

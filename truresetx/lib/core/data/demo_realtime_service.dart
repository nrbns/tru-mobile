import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/wellness_list.dart';
import '../../data/models/list_item.dart';
import 'sample_data.dart';

/// Demo real-time service that simulates live updates from a remote source.
/// Useful for local demos and unit tests when you don't want to wire Firestore yet.
final demoSampleDataProvider = Provider<SampleData>((ref) => SampleData());

final demoRealTimeListsProvider =
    StreamProvider.autoDispose<List<WellnessList>>((ref) {
  final controller = StreamController<List<WellnessList>>.broadcast();

  // Emit initial snapshot (cloned)
  controller.add(SampleData.getSampleLists()
      .map((l) => l.copyWith(items: l.items.map((i) => i.copyWith()).toList()))
      .toList());

  final rnd = Random();
  final timer = Timer.periodic(const Duration(seconds: 8), (_) {
    try {
      // Clone fresh lists so consumers receive new instances
      final lists = SampleData.getSampleLists()
          .map((l) =>
              l.copyWith(items: l.items.map((i) => i.copyWith()).toList()))
          .toList();

      // pick a random list and toggle a random item's completed flag
      if (lists.isNotEmpty) {
        final li = lists[rnd.nextInt(lists.length)];
        if (li.items.isNotEmpty) {
          final idx = rnd.nextInt(li.items.length);
          final it = li.items[idx];
          final toggled = it.copyWith(
            isCompleted: !it.isCompleted,
            completedAt: !it.isCompleted ? DateTime.now() : null,
          );
          final newItems = List<ListItem>.from(li.items);
          newItems[idx] = toggled;
          final newList =
              li.copyWith(items: newItems, updatedAt: DateTime.now());

          // replace
          final out = List<WellnessList>.from(lists);
          final listIndex = out.indexWhere((x) => x.id == newList.id);
          if (listIndex >= 0) out[listIndex] = newList;

          controller.add(out);
        }
      }
    } catch (e, st) {
      controller.addError(e, st);
    }
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

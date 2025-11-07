import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wellness_list.dart';
import '../models/list_item.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/realtime_service.dart';

class ListRepository {
  static const String _listsKey = 'wellness_lists';

  List<WellnessList> getLists() {
    final listsData = StorageService.listsBox
        .get(_listsKey, defaultValue: <Map<String, dynamic>>[]);
    if (listsData is List) {
      return listsData.map((data) {
        if (data is Map<String, dynamic>) {
          return WellnessList.fromJson(data);
        }
        return data as WellnessList;
      }).toList();
    }
    return [];
  }

  void saveLists(List<WellnessList> lists) {
    final listsData = lists.map((list) => list.toJson()).toList();
    StorageService.listsBox.put(_listsKey, listsData);
  }

  WellnessList? getListById(String id) {
    final lists = getLists();
    try {
      return lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  void saveList(WellnessList list) {
    final lists = getLists();
    final index = lists.indexWhere((l) => l.id == list.id);

    if (index >= 0) {
      lists[index] = list;
    } else {
      lists.add(list);
    }

    saveLists(lists);
  }

  void deleteList(String id) {
    final lists = getLists();
    lists.removeWhere((list) => list.id == id);
    saveLists(lists);
  }

  void addItemToList(String listId, ListItem item) {
    final list = getListById(listId);
    if (list != null) {
      final updatedList = list.copyWith(
        items: [...list.items, item],
        updatedAt: DateTime.now(),
      );
      saveList(updatedList);
    }
  }

  void updateItemInList(String listId, ListItem item) {
    final list = getListById(listId);
    if (list != null) {
      final updatedItems =
          list.items.map((i) => i.id == item.id ? item : i).toList();
      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      saveList(updatedList);
    }
  }

  void deleteItemFromList(String listId, String itemId) {
    final list = getListById(listId);
    if (list != null) {
      final updatedItems =
          list.items.where((item) => item.id != itemId).toList();
      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      saveList(updatedList);
    }
  }

  List<ListItem> getItemsByType(ListItemType type) {
    final lists = getLists();
    final allItems = <ListItem>[];
    for (final list in lists) {
      allItems.addAll(list.items.where((item) => item.type == type));
    }
    return allItems;
  }

  List<WellnessList> getListsByCategory(ListCategory category) {
    return getLists().where((list) => list.category == category).toList();
  }
}

final listRepositoryProvider =
    Provider<ListRepository>((ref) => ListRepository());

/// Stream provider that emits the current lists and updates when realtime
/// events for lists/items arrive. It yields an initial snapshot from local
/// storage and then emits a new snapshot whenever a relevant realtime event
/// is observed.
final listsRealtimeProvider = StreamProvider.autoDispose
    .family<List<WellnessList>, String>((ref, userId) {
  // initial snapshot from local storage
  final repo = ListRepository();
  final initial = repo.getLists();

  // Build a stream that first emits the local snapshot then emits updated
  // snapshots whenever a 'wellness_list' or 'list_item' event arrives.
  final controller = StreamController<List<WellnessList>>();

  // emit initial
  controller.add(initial);

  // Listen to the realtime provider via ref.listen and forward relevant
  // events into our controller. Using ref.listen avoids the deprecated
  // .stream API on providers.
  ref.listen<AsyncValue<Map<String, dynamic>>>(realtimeDataProvider,
      (previous, next) {
    next.whenData((event) {
      try {
        final type = event['type'] as String?;
        if (type == 'wellness_list' || type == 'list_item') {
          controller.add(repo.getLists());
        }
      } catch (e) {
        // ignore parse errors and continue
      }
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

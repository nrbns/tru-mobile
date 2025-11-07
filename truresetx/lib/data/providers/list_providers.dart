import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/wellness_list.dart';
import '../models/list_item.dart';
import '../repositories/list_repository.dart';

const Uuid _uuid = Uuid();

// Lists providers
final listsProvider =
    StateNotifierProvider<ListsNotifier, List<WellnessList>>((ref) {
  return ListsNotifier(ref.read(listRepositoryProvider));
});

final listByIdProvider = Provider.family<WellnessList?, String>((ref, id) {
  final lists = ref.watch(listsProvider);
  try {
    return lists.firstWhere((list) => list.id == id);
  } catch (e) {
    return null;
  }
});

final listsByCategoryProvider =
    Provider.family<List<WellnessList>, ListCategory>((ref, category) {
  final lists = ref.watch(listsProvider);
  return lists.where((list) => list.category == category).toList();
});

// Items providers
final itemsByTypeProvider =
    Provider.family<List<ListItem>, ListItemType>((ref, type) {
  final lists = ref.watch(listsProvider);
  final allItems = <ListItem>[];
  for (final list in lists) {
    allItems.addAll(list.items.where((item) => item.type == type));
  }
  return allItems;
});

// Statistics providers
final completionStatsProvider = Provider<Map<String, double>>((ref) {
  final lists = ref.watch(listsProvider);
  final stats = <String, double>{};

  for (final list in lists) {
    if (list.totalCount > 0) {
      stats[list.name] = list.completionPercentage;
    }
  }

  return stats;
});

class ListsNotifier extends StateNotifier<List<WellnessList>> {
  ListsNotifier(this._repository) : super([]) {
    loadLists();
  }
  final ListRepository _repository;

  void loadLists() {
    state = _repository.getLists();
  }

  void addList(WellnessList list) {
    _repository.saveList(list);
    loadLists();
  }

  void updateList(WellnessList list) {
    _repository.saveList(list);
    loadLists();
  }

  void deleteList(String id) {
    _repository.deleteList(id);
    loadLists();
  }

  void addItemToList(String listId, ListItem item) {
    _repository.addItemToList(listId, item);
    loadLists();
  }

  void updateItemInList(String listId, ListItem item) {
    _repository.updateItemInList(listId, item);
    loadLists();
  }

  void deleteItemFromList(String listId, String itemId) {
    _repository.deleteItemFromList(listId, itemId);
    loadLists();
  }

  void toggleItemCompletion(String listId, String itemId) {
    final list = _repository.getListById(listId);
    if (list != null) {
      final item = list.items.firstWhere((item) => item.id == itemId);
      final updatedItem = item.copyWith(
        isCompleted: !item.isCompleted,
        completedAt: !item.isCompleted ? DateTime.now() : null,
      );
      updateItemInList(listId, updatedItem);
    }
  }
}

// Helper functions for creating new items
ListItem createNewItem({
  required String title,
  String? description,
  required ListItemType type,
  int priority = 3,
  List<String> tags = const [],
}) {
  return ListItem(
    id: _uuid.v4(),
    title: title,
    description: description,
    type: type,
    priority: priority,
    tags: tags,
    createdAt: DateTime.now(),
  );
}

WellnessList createNewList({
  required String name,
  String? description,
  required ListCategory category,
  String? icon,
  String? color,
}) {
  return WellnessList(
    id: _uuid.v4(),
    name: name,
    description: description,
    category: category,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    icon: icon,
    color: color,
  );
}

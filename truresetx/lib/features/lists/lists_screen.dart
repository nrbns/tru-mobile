import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/list_providers.dart';
import '../../data/models/wellness_list.dart';
import '../../core/data/sample_data.dart';

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: ListCategory.values.length, vsync: this);

    // Load sample data if no lists exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lists = ref.read(listsProvider);
      if (lists.isEmpty) {
        _loadSampleData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    final sampleLists = SampleData.getSampleLists();
    for (final list in sampleLists) {
      ref.read(listsProvider.notifier).addList(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'load_sample':
                  _loadSampleData();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'load_sample',
                child: Text('Load Sample Data'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All Lists'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ListCategory.values.map((category) {
            return Tab(
              text: _getCategoryName(category),
              icon: Text(_getCategoryIcon(category)),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ListCategory.values.map((category) {
          final categoryLists =
              lists.where((list) => list.category == category).toList();
          return _buildCategoryView(context, category, categoryLists);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-list');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryView(
      BuildContext context, ListCategory category, List<WellnessList> lists) {
    if (lists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No lists in ${_getCategoryName(category)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first list to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return _buildListCard(context, list);
      },
    );
  }

  Widget _buildListCard(BuildContext context, WellnessList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/lists/detail/${list.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCategoryColor(list.category),
                    child: Text(
                      list.icon ?? _getCategoryIcon(list.category),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (list.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            list.description!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          // TODO: Implement edit
                          break;
                        case 'duplicate':
                          // TODO: Implement duplicate
                          break;
                        case 'delete':
                          _showDeleteDialog(list);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: list.completionPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(list.category),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${list.completedCount}/${list.totalCount}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(list.category),
                        ),
                  ),
                ],
              ),
              if (list.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: list.items.take(3).map((item) {
                    return Chip(
                      label: Text(
                        item.title,
                        style: TextStyle(
                          color: item.isCompleted
                              ? Colors.green
                              : Colors.grey[600],
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      backgroundColor: item.isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      side: BorderSide(
                        color:
                            item.isCompleted ? Colors.green : Colors.grey[300]!,
                      ),
                    );
                  }).toList(),
                ),
                if (list.items.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${list.items.length - 3} more items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(WellnessList list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text(
            'Are you sure you want to delete "${list.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(listsProvider.notifier).deleteList(list.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Lists'),
        content: const Text(
            'Are you sure you want to delete all lists? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final lists = ref.read(listsProvider);
              for (final list in lists) {
                ref.read(listsProvider.notifier).deleteList(list.id);
              }
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return Colors.red;
      case ListCategory.nutrition:
        return Colors.green;
      case ListCategory.mentalHealth:
        return Colors.blue;
      case ListCategory.spiritual:
        return Colors.purple;
      case ListCategory.habits:
        return Colors.orange;
      case ListCategory.goals:
        return Colors.pink;
      case ListCategory.general:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return '💪';
      case ListCategory.nutrition:
        return '🥗';
      case ListCategory.mentalHealth:
        return '🧠';
      case ListCategory.spiritual:
        return '✨';
      case ListCategory.habits:
        return '🔄';
      case ListCategory.goals:
        return '🎯';
      case ListCategory.general:
        return '📝';
    }
  }

  String _getCategoryName(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return 'Fitness';
      case ListCategory.nutrition:
        return 'Nutrition';
      case ListCategory.mentalHealth:
        return 'Mental Health';
      case ListCategory.spiritual:
        return 'Spiritual';
      case ListCategory.habits:
        return 'Habits';
      case ListCategory.goals:
        return 'Goals';
      case ListCategory.general:
        return 'General';
    }
  }
}

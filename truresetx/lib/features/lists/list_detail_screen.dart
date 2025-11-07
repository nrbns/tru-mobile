import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/list_providers.dart';
import '../../data/models/wellness_list.dart';
import '../../data/models/list_item.dart';

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(listByIdProvider(listId));

    if (list == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('List Not Found')),
        body: const Center(
          child: Text('This list could not be found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit list
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  // TODO: Implement share
                  break;
                case 'export':
                  // TODO: Implement export
                  break;
                case 'archive':
                  // TODO: Implement archive
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Text('Share'),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Export'),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Text('Archive'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Card(
            margin: const EdgeInsets.all(16),
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
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Total',
                          '${list.totalCount}',
                          Icons.list_alt,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Completed',
                          '${list.completedCount}',
                          Icons.check_circle,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Progress',
                          '${(list.completionPercentage * 100).toInt()}%',
                          Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
          ),

          // Items List
          Expanded(
            child: list.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first item to get started',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.items.length,
                    itemBuilder: (context, index) {
                      final item = list.items[index];
                      return _buildItemCard(context, ref, list, item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/lists/$listId/add-item');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
      BuildContext context, WidgetRef ref, WellnessList list, ListItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) {
            ref
                .read(listsProvider.notifier)
                .toggleItemCompletion(list.id, item.id);
          },
          activeColor: _getCategoryColor(list.category),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: item.description != null
            ? Text(
                item.description!,
                style: TextStyle(
                  color: item.isCompleted ? Colors.grey[500] : Colors.grey[600],
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriorityChip(item.priority),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // TODO: Implement edit item
                    break;
                  case 'duplicate':
                    // TODO: Implement duplicate item
                    break;
                  case 'delete':
                    _showDeleteItemDialog(context, ref, list, item);
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
        onTap: () {
          ref
              .read(listsProvider.notifier)
              .toggleItemCompletion(list.id, item.id);
        },
      ),
    );
  }

  Widget _buildPriorityChip(int priority) {
    Color color;
    String label;

    switch (priority) {
      case 1:
        color = Colors.grey;
        label = 'Low';
        break;
      case 2:
        color = Colors.blue;
        label = 'Medium';
        break;
      case 3:
        color = Colors.orange;
        label = 'High';
        break;
      case 4:
        color = Colors.red;
        label = 'Urgent';
        break;
      case 5:
        color = Colors.purple;
        label = 'Critical';
        break;
      default:
        color = Colors.grey;
        label = 'Normal';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteItemDialog(
      BuildContext context, WidgetRef ref, WellnessList list, ListItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(listsProvider.notifier)
                  .deleteItemFromList(list.id, item.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
}

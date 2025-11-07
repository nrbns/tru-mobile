import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/demo_realtime_service.dart';
import '../../data/models/list_item.dart';

class DemoListsScreen extends ConsumerWidget {
  const DemoListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(demoRealTimeListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Demo Real-time Lists')),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(child: Text('No demo lists available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lists.length,
            itemBuilder: (context, li) {
              final list = lists[li];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(child: Text(list.icon ?? '📁')),
                  title: Text(list.name),
                  subtitle: Text(
                      '${list.completedCount}/${list.totalCount} completed'),
                  children: list.items.map((it) => _buildItemTile(it)).toList(),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildItemTile(ListItem item) {
    return ListTile(
      leading: Checkbox(value: item.isCompleted, onChanged: null),
      title: Text(item.title),
      subtitle: item.description != null ? Text(item.description!) : null,
      trailing: Text('P${item.priority}'),
    );
  }
}

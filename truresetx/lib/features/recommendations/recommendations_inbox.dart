import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/recommendations_repository.dart';
import '../../core/services/current_user_provider.dart';

final _recsRepo = Provider((ref) => RecommendationsRepository.instance);

class RecommendationsInbox extends ConsumerWidget {
  const RecommendationsInbox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view recommendations')),
      );
    }

    final stream = ref.read(_recsRepo).streamRecommendations(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () async {
                // Open a simple input dialog to add a recommendation
                final result = await showDialog<Map<String, String?>>(
                  context: context,
                  builder: (ctx) {
                    final titleCtrl = TextEditingController();
                    final bodyCtrl = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add recommendation'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                          ),
                          TextField(
                            controller: bodyCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Body'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(null),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop({
                            'title': titleCtrl.text,
                            'body': bodyCtrl.text,
                          }),
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );

                if (result != null && result['title'] != null) {
                  await ref.read(_recsRepo).addRecommendation(
                        userId,
                        result['title']!,
                        result['body'] ?? '',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recommendation added')));
                  }
                }
              },
              child: const Text('Add recommendation'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Recommendation>>(
              stream: stream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('No recommendations yet'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = items[i];
                    return ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.lightbulb_outline)),
                      title: Text(r.title),
                      subtitle: Text(r.body),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () async {
                        // push by name and pass id via Navigator arguments for compatibility
                        Navigator.of(context)
                            .pushNamed('/recommendation', arguments: r.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

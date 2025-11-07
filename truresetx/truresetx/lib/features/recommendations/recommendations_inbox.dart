// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/recommendations_repository.dart';

final _recsRepo = Provider((ref) => RecommendationsRepository.instance);

final recsStreamProvider =
    StreamProvider.family<List<Recommendation>, String>((ref, userId) {
  final repo = ref.watch(_recsRepo);
  return repo.streamRecommendations(userId);
});

class RecommendationsInbox extends ConsumerStatefulWidget {
  final String userId;
  const RecommendationsInbox({super.key, required this.userId});

  @override
  ConsumerState<RecommendationsInbox> createState() =>
      _RecommendationsInboxState();
}

class _RecommendationsInboxState extends ConsumerState<RecommendationsInbox> {
  @override
  Widget build(BuildContext context) {
    final recs = ref.watch(recsStreamProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(title: Text('Recommendations')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(_recsRepo);
              // placeholder auto-generated recommendation
              await repo.addRecommendation(widget.userId, 'Wind-down breathing',
                  'Try a 5-min paced breathing before bed.');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recommendation generated')));
            },
            child: Text('Generate demo recommendation'),
          ),
          Expanded(
            child: recs.when(
              data: (items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final r = items[items.length - 1 - i];
                  return ListTile(title: Text(r.title), subtitle: Text(r.body));
                },
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text('Error loading recommendations')),
            ),
          )
        ],
      ),
    );
  }
}

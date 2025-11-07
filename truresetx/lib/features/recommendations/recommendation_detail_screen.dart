import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/recommendations_repository.dart';
import '../../core/services/current_user_provider.dart';

class RecommendationDetailScreen extends ConsumerStatefulWidget {
  final String?
      id; // optional if provided via Navigator arguments or path param
  const RecommendationDetailScreen({super.key, this.id});

  @override
  ConsumerState<RecommendationDetailScreen> createState() =>
      _RecommendationDetailScreenState();
}

class _RecommendationDetailScreenState
    extends ConsumerState<RecommendationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final idFromArgs =
        widget.id ?? ModalRoute.of(context)?.settings.arguments as String?;

    if (userId == null) {
      return const Scaffold(
          body: Center(child: Text('Sign in to view recommendation')));
    }
    if (idFromArgs == null) {
      return const Scaffold(
          body: Center(child: Text('Recommendation id missing')));
    }

    return FutureBuilder<List<Recommendation>>(
      future: RecommendationsRepository.instance.fetch(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snap.error}')));
        }
        final items = snap.data ?? [];
        final rec = items.firstWhere((r) => r.id == idFromArgs,
            orElse: () => Recommendation(
                id: '',
                title: 'Not found',
                body: 'No recommendation with that id',
                createdAt: DateTime.now()));
        if (rec.id.isEmpty) {
          return Scaffold(
              appBar: AppBar(title: const Text('Recommendation')),
              body: const Center(child: Text('Not found')));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Recommendation')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rec.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(rec.body, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text('Created: ${rec.createdAt.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/discipline_contract.dart';
import '../core/providers/agent_providers.dart';

/// Draggable sheet for creating and signing discipline contracts
class AgentContractSheet extends ConsumerWidget {
  final DisciplineContract draft;

  const AgentContractSheet({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disciplineNotifier = ref.read(disciplineProvider.notifier);
    bool isPublic = draft.isPublic;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Your Promise',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                draft.text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Share with buddies'),
              subtitle: const Text('Make this contract public for accountability'),
              value: isPublic,
              onChanged: (value) {
                // Update draft (would need state management for draft)
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Penalty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                draft.penaltyText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final signed = draft.copyWith(
                  signedAt: DateTime.now(),
                  isPublic: isPublic,
                );
                disciplineNotifier.sign(signed);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Sign Contract'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}


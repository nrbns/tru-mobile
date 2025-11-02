import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/agent_providers.dart';
import 'intent_card.dart';

/// Horizontal tray of micro-cards showing agent suggestions
class AgentSuggestionsTray extends ConsumerWidget {
  const AgentSuggestionsTray({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentsAsync = ref.watch(agentIntentProvider);

    return intentsAsync.when(
      data: (intents) {
        if (intents.isEmpty) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 76, left: 12, right: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => IntentCard(intent: intents[i]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: intents.length.clamp(0, 3),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/models/agent_intent.dart';
import '../core/providers/agent_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Micro-card for agent intent with actions
class IntentCard extends ConsumerWidget {
  final AgentIntent intent;

  const IntentCard({super.key, required this.intent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (intent.isExpired) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final metadata = intent.metadata ?? {};
    final route = metadata['route'] as String?;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(intent.icon),
                size: 20,
                color: theme.primaryColor,
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'swap', child: Text('Swap')),
                  const PopupMenuItem(value: 'why', child: Text('Why?')),
                  const PopupMenuItem(value: 'snooze', child: Text('Snooze')),
                  const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                ],
                onSelected: (value) {
                  final service = ref.read(agentServiceProvider);
                  if (value == 'dismiss') {
                    service.dismissIntent(intent.intentId);
                  }
                  // Handle other actions
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            intent.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (intent.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              intent.subtitle!,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: () {
              final service = ref.read(agentServiceProvider);
              service.acceptIntent(intent);
              if (route != null) {
                context.push(route);
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(intent.cta),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'restaurant':
        return Icons.restaurant;
      case 'chat':
        return Icons.chat;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.lightbulb;
    }
  }
}


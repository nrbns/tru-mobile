import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/agent_providers.dart';
import '../core/models/agent_intent.dart';
import '../core/models/agent_session.dart';
import 'agent_styles.dart';
import 'agent_avatar.dart';

/// Persistent mini-panel above tab bar showing agent status and quick actions
class AgentDock extends ConsumerWidget {
  const AgentDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(agentMoodProvider);
    final intentAsync = ref.watch(agentIntentProvider);
    final session = ref.watch(agentSessionProvider);
    final theme = AgentTheme.of(context, mood);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.borderRadius,
        boxShadow: theme.shadows,
      ),
      child: Row(
        children: [
          AgentAvatar(mood: mood),
          const SizedBox(width: 10),
          Expanded(
            child: _buildContent(context, intentAsync, session, theme),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            children: [
              _QuickAction(
                icon: Icons.edit,
                route: '/mind/mood-log',
                color: theme.primary,
              ),
              _QuickAction(
                icon: Icons.self_improvement,
                route: '/spirit/daily-practice',
                color: theme.primary,
              ),
              _QuickAction(
                icon: Icons.fitness_center,
                route: '/agent/overlay',
                color: theme.primary,
              ),
              _QuickAction(
                icon: Icons.auto_awesome,
                route: '/agent/energy-pulse',
                color: theme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncValue<List<AgentIntent>> intentAsync,
    AgentSession session,
    AgentTheme theme,
  ) {
    if (session.isActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            session.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: session.progress,
            backgroundColor: theme.surface.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
          ),
        ],
      );
    }

    return intentAsync.when(
      data: (intents) {
        final topIntent = intents.isNotEmpty ? intents.first : null;
        return Text(
          topIntent?.title ?? 'How are we feeling?',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.text,
              ),
        );
      },
      loading: () => Text(
        'Loading...',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: theme.text,
            ),
      ),
      error: (_, __) => Text(
        'How are we feeling?',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: theme.text,
            ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String route;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}


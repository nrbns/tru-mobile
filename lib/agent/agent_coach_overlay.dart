import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/agent_providers.dart';
import '../core/models/agent_session.dart';
import '../widgets/progress_ring.dart';

/// Full-screen overlay for live coaching (workout, breath, meditation)
class AgentCoachOverlay extends ConsumerWidget {
  final String? sessionType; // 'workout', 'breath', 'meditation'
  final String? sessionTitle;

  const AgentCoachOverlay({
    super.key,
    this.sessionType,
    this.sessionTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(agentSessionProvider);
    final sessionNotifier = ref.read(agentSessionProvider.notifier);

    // Initialize session if provided
    if (sessionType != null && !session.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sessionNotifier.startSession(AgentSession(
          sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
          type: sessionType!,
          title: sessionTitle ?? 'Coaching Session',
          progress: 0.0,
        ));
      });
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.isActive ? session.title : sessionTitle ?? 'Coaching',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 200,
                child: ProgressRing(
                  progress: session.isActive ? session.progress : 0.0,
                ),
              ),
              const SizedBox(height: 20),
              _CoachControls(
                session: session,
                onStart: () {
                  if (!session.isActive) {
                    sessionNotifier.startSession(AgentSession(
                      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: sessionType ?? 'general',
                      title: sessionTitle ?? 'Session',
                      progress: 0.0,
                    ));
                  }
                },
                onPause: () {
                  // TODO: Implement pause
                },
                onResume: () {
                  // TODO: Implement resume
                },
                onEnd: () {
                  sessionNotifier.endSession(completed: session.progress > 0.8);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachControls extends StatelessWidget {
  final AgentSession session;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  const _CoachControls({
    required this.session,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (!session.isActive) {
      return FilledButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (session.isPaused)
          IconButton(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Resume',
          )
        else
          IconButton(
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            tooltip: 'Pause',
          ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: onEnd,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('End'),
        ),
      ],
    );
  }
}


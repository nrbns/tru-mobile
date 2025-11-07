import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Floating Action Button with gesture support:
/// - Tap: Open chat
/// - Long-press: Voice input
/// - Swipe up: Posture camera
class AgentFab extends StatelessWidget {
  const AgentFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => context.push('/agent/voice'),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
          context.push('/agent/posture');
        }
      },
      child: FloatingActionButton(
        onPressed: () => context.push('/agent/chat'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}


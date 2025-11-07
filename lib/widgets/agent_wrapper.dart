import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../agent/agent_dock.dart';
import '../agent/agent_fab.dart';
import '../agent/agent_suggestions_tray.dart';

/// Wrapper that adds agent UI components (Dock, FAB, Suggestions) to any scaffold
class AgentWrapper extends ConsumerWidget {
  final Widget child;
  final bool showDock;
  final bool showFab;
  final bool showSuggestions;

  const AgentWrapper({
    super.key,
    required this.child,
    this.showDock = true,
    this.showFab = true,
    this.showSuggestions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Main content
        child,
        // Suggestions Tray (floating at bottom, above dock)
        if (showSuggestions)
          const Positioned(
            bottom: 200, // Above FAB and Dock
            left: 0,
            right: 0,
            child: AgentSuggestionsTray(),
          ),
        // Agent Dock (above bottom nav bar)
        if (showDock)
          const Positioned(
            bottom: 70, // Above bottom nav bar (~60px) + padding
            left: 0,
            right: 0,
            child: AgentDock(),
          ),
        // Agent FAB (floating, above dock)
        if (showFab)
          const Positioned(
            bottom: 135, // Above dock (adjusted for better spacing)
            right: 16,
            child: AgentFab(),
          ),
      ],
    );
  }
}


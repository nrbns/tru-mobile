import 'package:flutter/material.dart';
import '../core/models/agent_mood.dart';

/// Avatar widget that reflects agent mood
class AgentAvatar extends StatelessWidget {
  final AgentMood mood;
  final double size;

  const AgentAvatar({
    super.key,
    required this.mood,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (mood) {
      case AgentMood.calm:
        color = Colors.blue;
        icon = Icons.self_improvement;
        break;
      case AgentMood.neutral:
        color = Colors.grey;
        icon = Icons.person;
        break;
      case AgentMood.push:
        color = Colors.orange;
        icon = Icons.trending_up;
        break;
      case AgentMood.strict:
        color = Colors.red;
        icon = Icons.warning;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}


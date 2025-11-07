import 'package:flutter/material.dart';
import '../core/models/agent_mood.dart';

/// Adaptive theme for agent UI based on mood
class AgentTheme {
  final AgentMood mood;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color text;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  AgentTheme({
    required this.mood,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.text,
    required this.borderRadius,
    required this.shadows,
  });

  /// Get theme from context and mood
  static AgentTheme of(BuildContext context, AgentMood mood) {
    final baseTheme = Theme.of(context);
    final isDark = baseTheme.brightness == Brightness.dark;

    switch (mood) {
      case AgentMood.calm:
        return AgentTheme(
          mood: mood,
          surface: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD),
          primary: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2),
          accent: isDark ? const Color(0xFF90CAF9) : const Color(0xFF42A5F5),
          text: isDark ? Colors.white70 : Colors.black87,
          borderRadius: BorderRadius.circular(20),
          shadows: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withValues(alpha: 0.08),
              spreadRadius: 0,
            ),
          ],
        );

      case AgentMood.neutral:
        return AgentTheme(
          mood: mood,
          surface: baseTheme.cardColor,
          primary: baseTheme.primaryColor,
          accent: baseTheme.colorScheme.secondary,
          text: baseTheme.textTheme.bodyLarge?.color ?? Colors.black87,
          borderRadius: BorderRadius.circular(16),
          shadows: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
            ),
          ],
        );

      case AgentMood.push:
        return AgentTheme(
          mood: mood,
          surface: isDark ? const Color(0xFF5D4037) : const Color(0xFFFFE0B2),
          primary: isDark ? const Color(0xFFFF6F00) : const Color(0xFFE65100),
          accent: isDark ? const Color(0xFFFF8F00) : const Color(0xFFFF6F00),
          text: isDark ? Colors.white : Colors.black87,
          borderRadius: BorderRadius.circular(12),
          shadows: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.orange.withValues(alpha: 0.3),
              spreadRadius: 2,
            ),
          ],
        );

      case AgentMood.strict:
        return AgentTheme(
          mood: mood,
          surface: isDark ? const Color(0xFF4A2C2C) : const Color(0xFFFFEBEE),
          primary: isDark ? const Color(0xFFE53935) : const Color(0xFFC62828),
          accent: isDark ? const Color(0xFFFF5252) : const Color(0xFFD32F2F),
          text: isDark ? Colors.white : Colors.black87,
          borderRadius: BorderRadius.circular(8),
          shadows: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.red.withValues(alpha: 0.25),
              spreadRadius: 1,
            ),
          ],
        );
    }
  }
}


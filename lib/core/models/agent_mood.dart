/// Agent mood/persona that affects UI theme and tone
enum AgentMood {
  calm,    // Soft blues, rounded, gentle
  neutral, // Brand primary
  push,    // Energetic orange/red, strict tone
  strict,  // Red accents, tight microcopy
}

extension AgentMoodExtension on AgentMood {
  String get label {
    switch (this) {
      case AgentMood.calm:
        return 'Calm';
      case AgentMood.neutral:
        return 'Neutral';
      case AgentMood.push:
        return 'Push';
      case AgentMood.strict:
        return 'Strict';
    }
  }

  /// Determine mood from context (streaks, missed sessions, etc.)
  static AgentMood fromContext({
    required int missedSessions,
    required int currentStreak,
    required double stressLevel,
  }) {
    if (missedSessions >= 2) return AgentMood.strict;
    if (stressLevel > 0.7) return AgentMood.calm;
    if (currentStreak >= 7) return AgentMood.push;
    return AgentMood.neutral;
  }
}


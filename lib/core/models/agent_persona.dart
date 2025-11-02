/// Multi-identity awareness - Agent adapts its persona
enum AgentPersona {
  trainer,  // Push mode, fitness-focused
  sage,     // Spiritual, wisdom-focused
  friend,   // Casual, supportive
  coach,    // Balanced guidance
}

extension AgentPersonaExtension on AgentPersona {
  String get label {
    switch (this) {
      case AgentPersona.trainer:
        return 'Trainer';
      case AgentPersona.sage:
        return 'Sage';
      case AgentPersona.friend:
        return 'Friend';
      case AgentPersona.coach:
        return 'Coach';
    }
  }

  String get tone {
    switch (this) {
      case AgentPersona.trainer:
        return 'Let\'s push through! You\'ve got this.';
      case AgentPersona.sage:
        return 'Reflect on this wisdom...';
      case AgentPersona.friend:
        return 'Hey, how are you feeling today?';
      case AgentPersona.coach:
        return 'Here\'s what I notice and how we can improve...';
    }
  }

  /// Determine persona based on context
  static AgentPersona fromContext({
    required String timeOfDay,
    required double stressLevel,
    required String activityType,
  }) {
    if (activityType == 'workout' || activityType == 'fitness') {
      return AgentPersona.trainer;
    }
    if (activityType == 'meditation' || activityType == 'spiritual') {
      return AgentPersona.sage;
    }
    if (stressLevel > 0.7 || timeOfDay == 'evening') {
      return AgentPersona.friend;
    }
    return AgentPersona.coach;
  }
}


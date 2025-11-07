/// User-Agent Connection Levels
enum BondLevel {
  basic,      // Level 1: Chat & tasks
  interactive, // Level 2: Real-time guidance
  evolving,   // Level 3: Emotional sync
  merged,     // Level 4: Life twin
}

extension BondLevelExtension on BondLevel {
  String get label {
    switch (this) {
      case BondLevel.basic:
        return 'Basic Connection';
      case BondLevel.interactive:
        return 'Interactive Guide';
      case BondLevel.evolving:
        return 'Evolving Partnership';
      case BondLevel.merged:
        return 'Life Twin';
    }
  }

  String get description {
    switch (this) {
      case BondLevel.basic:
        return 'Agent tracks workouts, goals, and motivation.';
      case BondLevel.interactive:
        return 'Agent joins you in AR workouts and meditations.';
      case BondLevel.evolving:
        return 'Agent syncs with your emotions and mood cycles.';
      case BondLevel.merged:
        return 'Agent designs your full daily rhythm.';
    }
  }

  int get requiredDays {
    switch (this) {
      case BondLevel.basic:
        return 0;
      case BondLevel.interactive:
        return 7;
      case BondLevel.evolving:
        return 30;
      case BondLevel.merged:
        return 90;
    }
  }

  static BondLevel fromDaysActive(int days) {
    if (days >= 90) return BondLevel.merged;
    if (days >= 30) return BondLevel.evolving;
    if (days >= 7) return BondLevel.interactive;
    return BondLevel.basic;
  }
}


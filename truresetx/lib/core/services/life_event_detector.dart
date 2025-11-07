// Simple LifeEventDetector MVP
// This is a local heuristic-based detector to demo Life Event Recognition.
class LifeEventDetector {
  LifeEventDetector();

  /// Runs lightweight heuristics over a data snapshot to suggest life events.
  /// Example input keys: 'avg_sleep_hours', 'mood_avg', 'recent_spend_change_percent', 'event_flags'
  List<String> detectFromSnapshot(Map<String, dynamic> snapshot) {
    final events = <String>[];
    final sleep = (snapshot['avg_sleep_hours'] as num?)?.toDouble();
    final mood = (snapshot['mood_avg'] as num?)?.toDouble();
    final spendChange =
        (snapshot['recent_spend_change_percent'] as num?)?.toDouble();

    if (sleep != null && sleep < 5.0) {
      events.add('sleep_deprivation');
    }
    if (mood != null && mood <= 3.5) {
      events.add('sustained_low_mood');
    }
    if (spendChange != null && spendChange > 50.0) {
      events.add('financial_shock');
    }

    final flags = snapshot['event_flags'] as List<String>?;
    if (flags != null) {
      for (final f in flags) {
        if (f == 'breakup') events.add('love_failure');
        if (f == 'job_loss') events.add('job_loss');
        if (f == 'harassment') events.add('harassment');
      }
    }

    return events;
  }
}

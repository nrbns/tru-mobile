import 'package:flutter_test/flutter_test.dart';
import 'package:truresetx/core/services/life_event_detector.dart';

void main() {
  group('LifeEventDetector', () {
    final detector = LifeEventDetector();

    test('detects sleep, mood, spend and flags', () {
      final snapshot = {
        'avg_sleep_hours': 4.5,
        'mood_avg': 3.0,
        'recent_spend_change_percent': 60.0,
        'event_flags': <String>['breakup', 'job_loss']
      };

      final events = detector.detectFromSnapshot(snapshot);

      expect(events, contains('sleep_deprivation'));
      expect(events, contains('sustained_low_mood'));
      expect(events, contains('financial_shock'));
      expect(events, contains('love_failure'));
      expect(events, contains('job_loss'));
    });

    test('returns empty list for empty snapshot', () {
      final events = detector.detectFromSnapshot({});
      expect(events, isEmpty);
    });
  });
}

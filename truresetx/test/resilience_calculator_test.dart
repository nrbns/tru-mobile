import 'package:flutter_test/flutter_test.dart';
import 'package:truresetx/core/services/resilience_calculator.dart';

void main() {
  group('ResilienceCalculator', () {
    final calc = ResilienceCalculator();

    test('computes expected score for typical inputs', () {
      // Note: sleepMin is treated as hours in the implementation.
      final score = calc.computeScore(
        moodAvg: 6.0,
        sleepMin: 8,
        financialStress: 0.2,
        activityMin: 60,
        socialScore: 0.6,
        spiritualScore: 0.7,
      );

      // Computed expectation (manual): ~58
      expect(score, equals(58));
    });

    test('caps at 100 for very high mood', () {
      final high = calc.computeScore(moodAvg: 100.0);
      expect(high, equals(100));
    });

    test('returns base 50 when input is NaN', () {
      final nanScore = calc.computeScore(moodAvg: double.nan);
      expect(nanScore, equals(50));
    });
  });
}

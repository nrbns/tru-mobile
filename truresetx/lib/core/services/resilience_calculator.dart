// Simple ResilienceScore calculator (0..100)
class ResilienceCalculator {
  ResilienceCalculator();

  /// Compute a resilience score using a few inputs.
  /// Inputs are optional and normalized inside.
  int computeScore(
      {double? moodAvg,
      int? sleepMin,
      double? financialStress,
      int? activityMin,
      double? socialScore,
      double? spiritualScore}) {
    // Base from 50
    double score = 50.0;
    if (moodAvg != null) {
      score += (moodAvg - 5.5) * 4.0; // mood range effect
    }
    if (sleepMin != null) {
      score += ((sleepMin / 8.0) - 1.0) * 8.0; // 8 hours baseline
    }
    if (financialStress != null) {
      score -= financialStress * 10.0; // 0..1 stress
    }
    if (activityMin != null) {
      score += (activityMin / 30.0) * 3.0; // each 30m adds
    }
    if (socialScore != null) {
      score += (socialScore - 0.5) * 10.0;
    }
    if (spiritualScore != null) {
      score += (spiritualScore - 0.5) * 6.0;
    }

    if (score.isNaN) score = 50.0;
    if (score < 0) score = 0.0;
    if (score > 100) score = 100.0;
    return score.round();
  }
}

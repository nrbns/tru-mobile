// Minimal EmotionalTwin MVP: learns simple user stats and predicts short-term risk
class EmotionalTwin {
  EmotionalTwin();

  // lightweight state: avgMood and recentVariance
  double avgMood = 6.5;
  double moodVariance = 1.2;

  void updateFromMoodLogs(List<int> recentMoods) {
    if (recentMoods.isEmpty) return;
    final sum = recentMoods.fold<int>(0, (p, e) => p + e);
    avgMood = sum / recentMoods.length;
    final mean = avgMood;
    final variance = recentMoods
            .map((m) => (m - mean) * (m - mean))
            .fold(0.0, (p, e) => p + e) /
        recentMoods.length;
    moodVariance = variance;
  }

  /// Returns a simple probability (0..1) that the user may have a near-term meltdown.
  double predictMeltdownProbability() {
    // More variance and lower mood increases probability
    var p = 0.0;
    p += (7.0 - avgMood) * 0.08; // avgMood 7 -> low contribution
    p += (moodVariance / 4.0) * 0.2; // more variance increases risk
    if (p < 0) p = 0.0;
    if (p > 1) p = 1.0;
    return p;
  }

  String voiceTonePreference() {
    // placeholder: selects tone based on avgMood
    if (avgMood >= 7) return 'witty';
    if (avgMood >= 5) return 'calm';
    return 'compassionate';
  }
}

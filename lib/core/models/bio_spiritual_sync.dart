class BioSpiritualSyncData {
  final String userId;
  final int mood; // 1-10
  final String? cyclePhase;
  final int sleepQuality; // 1-10
  final int stressScore; // 1-10
  final List<String> recommendations;
  final String suggestedPractice;

  BioSpiritualSyncData({
    required this.userId,
    required this.mood,
    required this.cyclePhase,
    required this.sleepQuality,
    required this.stressScore,
    required this.recommendations,
    required this.suggestedPractice,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'mood': mood,
        'cyclePhase': cyclePhase,
        'sleepQuality': sleepQuality,
        'stressScore': stressScore,
        'recommendations': recommendations,
        'suggestedPractice': suggestedPractice,
      };
}

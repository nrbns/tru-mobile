class KarmaLog {
  final String userId;
  final String activity;
  final int impactScore; // -10..+10
  final String? reflection;
  final DateTime timestamp;
  final String category; // 'virtue', 'discipline', 'service', etc.

  KarmaLog({
    required this.userId,
    required this.activity,
    required this.impactScore,
    required this.reflection,
    required this.timestamp,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'activity': activity,
        'impactScore': impactScore,
        'reflection': reflection,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
      };
}

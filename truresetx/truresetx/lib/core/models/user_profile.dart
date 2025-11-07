// Lightweight user profile model and HealthFocusType enum
enum HealthFocusType { general, diabetic, pcos }

class UserProfile {
  final String userId;
  final HealthFocusType focusType;
  final String? fullName;
  final String? avatarUrl;

  const UserProfile({
    required this.userId,
    this.focusType = HealthFocusType.general,
    this.fullName,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'focusType': focusType.toString().split('.').last,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) {
    final focusRaw = (m['focusType'] ?? 'general') as String;
    HealthFocusType focus;
    switch (focusRaw) {
      case 'diabetic':
        focus = HealthFocusType.diabetic;
        break;
      case 'pcos':
        focus = HealthFocusType.pcos;
        break;
      default:
        focus = HealthFocusType.general;
    }

    return UserProfile(
      userId: m['userId'] as String,
      focusType: focus,
      fullName: m['fullName'] as String?,
      avatarUrl: m['avatarUrl'] as String?,
    );
  }
}

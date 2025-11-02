/// Discipline contract for accountability
class DisciplineContract {
  final String id;
  final String text; // Promise text
  final bool isPublic; // Share with buddies
  final String penaltyText; // What happens on violation
  final DateTime? signedAt;
  final DateTime? violatedAt;
  final DateTime createdAt;
  final String? buddyId; // Optional accountability partner

  DisciplineContract({
    required this.id,
    required this.text,
    this.isPublic = false,
    required this.penaltyText,
    this.signedAt,
    this.violatedAt,
    DateTime? createdAt,
    this.buddyId,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isSigned => signedAt != null;
  bool get isViolated => violatedAt != null;
  bool get isActive => isSigned && !isViolated;

  factory DisciplineContract.draft({
    required String text,
    required String penaltyText,
    bool isPublic = false,
    String? buddyId,
  }) {
    return DisciplineContract(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isPublic: isPublic,
      penaltyText: penaltyText,
      buddyId: buddyId,
    );
  }

  DisciplineContract copyWith({
    String? id,
    String? text,
    bool? isPublic,
    String? penaltyText,
    DateTime? signedAt,
    DateTime? violatedAt,
    DateTime? createdAt,
    String? buddyId,
  }) {
    return DisciplineContract(
      id: id ?? this.id,
      text: text ?? this.text,
      isPublic: isPublic ?? this.isPublic,
      penaltyText: penaltyText ?? this.penaltyText,
      signedAt: signedAt ?? this.signedAt,
      violatedAt: violatedAt ?? this.violatedAt,
      createdAt: createdAt ?? this.createdAt,
      buddyId: buddyId ?? this.buddyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isPublic': isPublic,
      'penaltyText': penaltyText,
      'signedAt': signedAt?.millisecondsSinceEpoch,
      'violatedAt': violatedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'buddyId': buddyId,
    };
  }

  factory DisciplineContract.fromJson(Map<String, dynamic> json) {
    return DisciplineContract(
      id: json['id'] as String,
      text: json['text'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      penaltyText: json['penaltyText'] as String,
      signedAt: json['signedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['signedAt'] as int)
          : null,
      violatedAt: json['violatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['violatedAt'] as int)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      buddyId: json['buddyId'] as String?,
    );
  }
}


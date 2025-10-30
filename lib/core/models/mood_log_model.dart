import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLogModel {
  final String id;
  final String uid;
  final DateTime at;
  final int score; // 1-10
  final List<String> emotions;
  final String? note;
  final String? voiceUrl;

  MoodLogModel({
    required this.id,
    required this.uid,
    required this.at,
    required this.score,
    required this.emotions,
    this.note,
    this.voiceUrl,
  });

  factory MoodLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MoodLogModel(
      id: doc.id,
      uid: doc.reference.parent.parent!.id,
      at: data['at']?.toDate() ?? DateTime.now(),
      score: data['score'] ?? 5,
      emotions: List<String>.from(data['emotions'] ?? []),
      note: data['note'],
      voiceUrl: data['voice_url'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'at': Timestamp.fromDate(at),
      'score': score,
      'emotions': emotions,
      'note': note,
      'voice_url': voiceUrl,
    };
  }
}

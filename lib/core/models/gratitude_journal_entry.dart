import 'package:cloud_firestore/cloud_firestore.dart';

class GratitudeJournalEntry {
  final String id;
  final String userId;
  final String type; // 'gratitude' or 'reflection'
  final String text;
  final List<String> emotionTags;
  final DateTime date;

  GratitudeJournalEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.text,
    required this.emotionTags,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'text': text,
      'emotionTags': emotionTags,
      'date': Timestamp.fromDate(date),
    };
  }

  static GratitudeJournalEntry fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['date'];
    final parsedDate = ts is Timestamp ? ts.toDate() : DateTime.now();
    return GratitudeJournalEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'gratitude',
      text: data['text'] as String? ?? '',
      emotionTags: List<String>.from(data['emotion_tags'] ?? data['emotionTags'] ?? const []),
      date: parsedDate,
    );
  }
}



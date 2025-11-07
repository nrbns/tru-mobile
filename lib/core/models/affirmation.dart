class Affirmation {
  final String id;
  final String type; // 'healing', 'confidence', etc.
  final String text;
  final String? audioURL;
  final int repeatCount;
  final String category;

  Affirmation({
    required this.id,
    required this.type,
    required this.text,
    required this.audioURL,
    required this.repeatCount,
    required this.category,
  });

  factory Affirmation.fromMap(String id, Map<String, dynamic> data) {
    return Affirmation(
      id: id,
      type: data['type'] as String? ?? 'healing',
      text: data['text'] as String? ?? '',
      audioURL: data['audioURL'] as String?,
      repeatCount: data['repeatCount'] as int? ?? 1,
      category: data['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'text': text,
        'audioURL': audioURL,
        'repeatCount': repeatCount,
        'category': category,
      };
}

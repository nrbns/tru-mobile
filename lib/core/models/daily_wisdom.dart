class DailyWisdom {
  final String id;
  final String translation;
  final String? verse;
  final String? meaning;
  final String? source;
  final String? author;
  final List<String>? tags;
  final DateTime servedAt;
  final String? category;
  // Additional optional metadata used by some screens
  final String? language;
  final String? era;
  final String? tradition;
  final String? level;
  final List<String>? moodFit;

  DailyWisdom({
    required this.id,
    required this.translation,
    this.verse,
    this.meaning,
    this.source,
    this.author,
    this.tags,
    required this.servedAt,
    this.category,
    this.language,
    this.era,
    this.tradition,
    this.level,
    this.moodFit,
  });

  factory DailyWisdom.fromMap(String id, Map<String, dynamic> m) {
    // Normalize servedAt which can be stored as int (ms), Firestore Timestamp,
    // or missing.
    DateTime servedAt;
    final sa = m['servedAt'] ?? m['createdAt'];
    if (sa is int) {
      servedAt = DateTime.fromMillisecondsSinceEpoch(sa);
    } else if (sa is String) {
      final parsed = int.tryParse(sa);
      if (parsed != null) {
        servedAt = DateTime.fromMillisecondsSinceEpoch(parsed);
      } else {
        servedAt = DateTime.now();
      }
    } else if (sa is Map && sa['seconds'] != null) {
      // Firestore timestamp as map (when serialized)
      final seconds = sa['seconds'] as int? ?? 0;
      servedAt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else {
      servedAt = DateTime.now();
    }

    return DailyWisdom(
      id: id,
      translation: (m['translation'] ?? '').toString(),
      verse: (m['verse'] ?? '') == '' ? null : m['verse'] as String?,
      meaning: (m['meaning'] ?? '') == '' ? null : m['meaning'] as String?,
      source: (m['source'] ?? '') == '' ? null : m['source'] as String?,
      author: (m['author'] ?? '') == '' ? null : m['author'] as String?,
      tags: (m['tags'] is List)
          ? (m['tags'] as List).map((e) => e.toString()).toList()
          : null,
      servedAt: servedAt,
      category: (m['category'] ?? '') == '' ? null : m['category'] as String?,
      language: (m['language'] ?? '') == '' ? null : m['language'] as String?,
      era: (m['era'] ?? '') == '' ? null : m['era'] as String?,
      tradition:
          (m['tradition'] ?? '') == '' ? null : m['tradition'] as String?,
      level: (m['level'] ?? '') == '' ? null : m['level'] as String?,
      moodFit: (m['moodFit'] is List)
          ? (m['moodFit'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'translation': translation,
        'verse': verse,
        'meaning': meaning,
        'source': source,
        'author': author,
        'tags': tags,
        'servedAt': servedAt.millisecondsSinceEpoch,
        'category': category,
        'language': language,
        'era': era,
        'tradition': tradition,
        'level': level,
        'moodFit': moodFit,
      };
}

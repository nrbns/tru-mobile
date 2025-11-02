import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedWisdom() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  final items = [
    {
      'translation': 'Silence is a source of great strength.',
      'meaning': 'Quiet your mind to gain clarity and energy.',
      'source': 'Lao Tzu',
      'author': 'Lao Tzu',
      'tags': ['silence', 'strength'],
      'category': 'Tao',
      'published': true,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    },
    {
      'translation': 'Be here now.',
      'meaning': 'Anchor attention in the present.',
      'source': 'Ram Dass',
      'author': 'Ram Dass',
      'tags': ['presence', 'mindfulness'],
      'category': 'Modern',
      'published': true,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    }
  ];

  for (final it in items) {
    final ref = db.collection('wisdom').doc();
    batch.set(ref, it);
  }
  await batch.commit();

  // Set daily
  await db.collection('wisdom_daily').doc('today').set({
    'id': 'seed-today',
    ...items.first,
    'servedAt': DateTime.now().millisecondsSinceEpoch
  });
}

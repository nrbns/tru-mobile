import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_keys.dart';

class FaithService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _scripturesRef =>
      _firestore.collection(FirestoreKeys.scriptures);
  CollectionReference get _devotionalsRef =>
      _firestore.collection(FirestoreKeys.devotionals);
  CollectionReference get _prayerTimesRef =>
      _firestore.collection(FirestoreKeys.prayerTimes);

  // Christian stubs with better error handling
  Future<List<Map<String, dynamic>>> getDailyVerses({int limit = 1}) async {
    try {
      final snap = await _scripturesRef
          .where('tradition', isEqualTo: 'christian')
          .limit(limit)
          .get();
      if (snap.docs.isEmpty) {
        // Return fallback verse if none found
        return [
          {
            'id': 'fallback',
            'text':
                'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you.',
            'book': 'Jeremiah',
            'chapter': 29,
            'verse': 11,
            'translation': 'NIV',
          }
        ];
      }
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        return {'id': d.id, ...data};
      }).toList();
    } catch (e) {
      // Return fallback on error
      return [
        {
          'id': 'fallback',
          'text': 'Be still and know that I am God.',
          'book': 'Psalms',
          'chapter': 46,
          'verse': 10,
        }
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getDevotionals({int limit = 10}) async {
    try {
      final snap = await _devotionalsRef
          .where('tradition', isEqualTo: 'christian')
          .limit(limit)
          .get();
      if (snap.docs.isEmpty) return [];
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        return {'id': d.id, ...data};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Islamic stubs with better error handling
  Future<List<Map<String, dynamic>>> getDailyAyah({int limit = 1}) async {
    try {
      final snap = await _scripturesRef
          .where('tradition', isEqualTo: 'islamic')
          .limit(limit)
          .get();
      if (snap.docs.isEmpty) {
        return [
          {
            'id': 'fallback',
            'text': 'وَمَا خَلَقْتُ الْجِنَّ وَالْإِنْسَ إِلَّا لِيَعْبُدُونِ',
            'translation':
                'And I did not create the jinn and mankind except to worship Me.',
            'surah': 'Adh-Dhariyat',
            'ayah': 56,
          }
        ];
      }
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        return {'id': d.id, ...data};
      }).toList();
    } catch (e) {
      return [
        {
          'id': 'fallback',
          'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          'translation':
              'In the name of Allah, the Most Gracious, the Most Merciful.',
        }
      ];
    }
  }

  Future<Map<String, dynamic>?> getPrayerTimesForDate(String dateKey) async {
    try {
      final doc = await _prayerTimesRef.doc(dateKey).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {'id': doc.id, ...data};
    } catch (e) {
      return null;
    }
  }

  // Jewish stubs with better error handling
  Future<List<Map<String, dynamic>>> getLessons(
      {String category = 'Torah', int limit = 10}) async {
    try {
      final snap = await _firestore
          .collection(FirestoreKeys.lessons)
          .where('tradition', isEqualTo: 'jewish')
          .where('category', isEqualTo: category)
          .limit(limit)
          .get();
      if (snap.docs.isEmpty) return [];
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }
}

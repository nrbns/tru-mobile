import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/wisdom_model.dart';
import 'mood_service.dart';

/// Service for Wisdom & Legends module
/// Handles daily wisdom, library, reflections, and AI integration
class WisdomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final MoodService _moodService = MoodService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('WisdomService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _wisdomRef => _firestore.collection('wisdom');

  CollectionReference get _wisdomReflectionsRef {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wisdom_reflections');
  }

  /// Get daily wisdom personalized by mood and spiritual path
  Future<WisdomModel> getDailyWisdom({
    String? userMood,
    String? spiritualPath,
    String? category,
  }) async {
    try {
      // Get user's current mood if not provided
      if (userMood == null) {
        final recentMoods = await _moodService.getMoodLogs(limit: 1);
        if (recentMoods.isNotEmpty) {
          final mood = recentMoods.first.score;
          if (mood < 4) {
            userMood = 'sad';
          } else if (mood < 6) {
            userMood = 'neutral';
          } else if (mood < 8) {
            userMood = 'happy';
          } else {
            userMood = 'energized';
          }
        }
      }

      // Call Cloud Function for personalized wisdom
      final callable = _functions.httpsCallable('getDailyWisdom');
      final result = await callable.call({
        'user_mood': userMood,
        'spiritual_path': spiritualPath,
        'category': category,
      });

      final data = Map<String, dynamic>.from(result.data);
      // Ensure id is included
      if (!data.containsKey('id') && result.data is Map) {
        final resultData = result.data as Map<String, dynamic>;
        data['id'] = resultData['id'] ?? resultData['wisdom_id'] ?? 'default';
      }
      return WisdomModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get daily wisdom: $e');
    }
  }

  /// Get wisdom by ID
  Future<WisdomModel?> getWisdomById(String wisdomId) async {
    final doc = await _wisdomRef.doc(wisdomId).get();
    if (!doc.exists) return null;
    return WisdomModel.fromFirestore(doc);
  }

  /// Get wisdom library with filters
  Future<List<WisdomModel>> getWisdomLibrary({
    String? source,
    String? category,
    List<String>? tags,
    String? moodFit,
    String? tradition,
    int limit = 50,
  }) async {
    Query query = _wisdomRef.limit(limit);

    if (source != null) {
      query = query.where('source', isEqualTo: source);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }
    if (moodFit != null) {
      query = query.where('mood_fit', arrayContains: moodFit);
    }
    if (tradition != null) {
      query = query.where('tradition', isEqualTo: tradition);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => WisdomModel.fromFirestore(doc)).toList();
  }

  /// Stream wisdom library for real-time updates
  Stream<List<WisdomModel>> streamWisdomLibrary({
    String? source,
    String? category,
    int limit = 50,
  }) {
    Query query = _wisdomRef.limit(limit);

    if (source != null) {
      query = query.where('source', isEqualTo: source);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => WisdomModel.fromFirestore(doc)).toList());
  }

  /// Get legends wisdom (quotes from famous masters)
  Future<List<WisdomModel>> getLegendsWisdom({
    String? author,
    int limit = 20,
  }) async {
    Query query = _wisdomRef.where('author', isNotEqualTo: null).limit(limit);

    if (author != null) {
      query = query.where('author', isEqualTo: author);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => WisdomModel.fromFirestore(doc)).toList();
  }

  /// Save wisdom to user's personal library
  Future<void> saveToMyWisdom(String wisdomId) async {
    final uid = _requireUid();
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_wisdom')
        .doc(wisdomId)
        .set({
      'wisdom_id': wisdomId,
      'saved_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get user's saved wisdom
  Stream<List<WisdomModel>> streamSavedWisdom() {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_wisdom')
        .snapshots()
        .asyncMap((snapshot) async {
      final wisdomIds = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return data['wisdom_id'] as String?;
          })
          .whereType<String>()
          .toList();

      if (wisdomIds.isEmpty) return [];

      final wisdomDocs = await Future.wait(
        wisdomIds.map((id) => _wisdomRef.doc(id).get()),
      );

      return wisdomDocs
          .where((doc) => doc.exists)
          .map((doc) => WisdomModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Create reflection on wisdom
  Future<void> reflectOnWisdom({
    required String wisdomId,
    String? reflectionText,
    int? moodBefore,
    int? moodAfter,
    List<String>? insights,
  }) async {
    final uid = _requireUid();
    await _wisdomReflectionsRef.add({
      'wisdom_id': wisdomId,
      'user_id': uid,
      'reflection_text': reflectionText,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'insights': insights ?? [],
      'applied_today': false,
      'reflected_at': FieldValue.serverTimestamp(),
    });
  }

  /// Mark wisdom as applied today (for challenges)
  Future<void> markWisdomApplied(String wisdomId) async {
    final uid = _requireUid();
    await _wisdomReflectionsRef.add({
      'wisdom_id': wisdomId,
      'user_id': uid,
      'applied_today': true,
      'reflected_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get user's wisdom reflections
  Stream<List<WisdomReflectionModel>> streamWisdomReflections(
      {int limit = 30}) {
    return _wisdomReflectionsRef
        .orderBy('reflected_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return WisdomReflectionModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing reflection: $e');
          // Return a basic model if parsing fails
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return WisdomReflectionModel(
            id: doc.id,
            wisdomId: data['wisdom_id'] ?? '',
            userId: data['user_id'] ?? _auth.currentUser?.uid ?? '',
            reflectionText: data['reflection_text'],
            moodBefore: data['mood_before'],
            moodAfter: data['mood_after'],
            insights: data['insights'] != null
                ? List<String>.from(data['insights'])
                : null,
            appliedToday: data['applied_today'] ?? false,
            reflectedAt: (data['reflected_at'] as Timestamp?)?.toDate(),
          );
        }
      }).toList();
    });
  }

  /// Get wisdom streak (consecutive days of wisdom reading)
  Future<int> getWisdomStreak() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime currentDate = startOfDay;

    // Check up to 365 days back
    for (int i = 0; i < 365; i++) {
      final endOfDay = currentDate.add(const Duration(days: 1));
      final snapshot = await _wisdomReflectionsRef
          .where('reflected_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(currentDate))
          .where('reflected_at', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break;
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Search wisdom by text
  Future<List<WisdomModel>> searchWisdom(String query, {int limit = 20}) async {
    final snapshot = await _wisdomRef
        .where('translation', isGreaterThanOrEqualTo: query)
        .where('translation', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => WisdomModel.fromFirestore(doc)).toList();
  }

  /// Get AI reflection on wisdom (connects verse to user's current state)
  Future<Map<String, dynamic>> getAIReflection({
    required String wisdomId,
    required String reflectionPrompt,
  }) async {
    try {
      final callable = _functions.httpsCallable('getWisdomReflection');
      final result = await callable.call({
        'wisdom_id': wisdomId,
        'reflection_prompt': reflectionPrompt,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get AI reflection: $e');
    }
  }

  /// Get available sources (Thirukkural, Gita, etc.)
  Future<List<String>> getAvailableSources() async {
    final snapshot = await _wisdomRef.get();
    final sources = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final source = data['source'] as String?;
      if (source != null) sources.add(source);
    }
    return sources.toList()..sort();
  }

  /// Get available categories
  Future<List<String>> getAvailableCategories() async {
    final snapshot = await _wisdomRef.get();
    final categories = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category'] as String?;
      if (category != null) categories.add(category);
    }
    return categories.toList()..sort();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Retrieval Augmented Generation (RAG) Service
///
/// Retrieves relevant context from Firestore based on user queries
/// to provide context-aware responses from the AI
class RAGService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieve relevant context from user's data
  Future<Map<String, dynamic>> retrieveRelevantContext(String query) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return {'context': '', 'doc_ids': []};
    final uid = currentUser.uid;
    final lowerQuery = query.toLowerCase();

    // Keywords for different data types
    final moodKeywords = [
      'mood',
      'feeling',
      'emotion',
      'happiness',
      'sad',
      'anxiety',
      'stress'
    ];
    final nutritionKeywords = [
      'food',
      'meal',
      'diet',
      'calorie',
      'nutrition',
      'eating',
      'snack'
    ];
    final workoutKeywords = [
      'workout',
      'exercise',
      'fitness',
      'gym',
      'run',
      'training'
    ];
    final spiritualKeywords = [
      'prayer',
      'meditation',
      'practice',
      'spiritual',
      'faith',
      'belief'
    ];

    List<String> retrievedDocs = [];
    String context = '';

    // Check query type and retrieve relevant data
    if (_containsKeywords(lowerQuery, moodKeywords)) {
      final moodContext = await _getMoodContext(uid);
      context += moodContext['text'] ?? '';
      retrievedDocs.addAll(moodContext['doc_ids'] ?? []);
    }

    if (_containsKeywords(lowerQuery, nutritionKeywords)) {
      final nutritionContext = await _getNutritionContext(uid);
      context += nutritionContext['text'] ?? '';
      retrievedDocs.addAll(nutritionContext['doc_ids'] ?? []);
    }

    if (_containsKeywords(lowerQuery, workoutKeywords)) {
      final workoutContext = await _getWorkoutContext(uid);
      context += workoutContext['text'] ?? '';
      retrievedDocs.addAll(workoutContext['doc_ids'] ?? []);
    }

    if (_containsKeywords(lowerQuery, spiritualKeywords)) {
      final spiritualContext = await _getSpiritualContext(uid);
      context += spiritualContext['text'] ?? '';
      retrievedDocs.addAll(spiritualContext['doc_ids'] ?? []);
    }

    // Get today's summary as additional context
    final todayContext = await _getTodayContext(uid);
    context += todayContext['text'] ?? '';
    retrievedDocs.addAll(todayContext['doc_ids'] ?? []);

    return {
      'context': context.trim(),
      'doc_ids': retrievedDocs.toSet().toList(),
    };
  }

  bool _containsKeywords(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword));
  }

  /// Get mood-related context
  Future<Map<String, dynamic>> _getMoodContext(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('mood_logs')
        .orderBy('at', descending: true)
        .limit(5)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'text': '', 'doc_ids': []};
    }

    String context = '\nRecent mood data:\n';
    List<String> docIds = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final score = data['score'] ?? 0;
      final emotions = (data['emotions'] as List?)?.join(', ') ?? '';
      final note = data['note'] ?? '';
      final date =
          (data['at'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '';

      context +=
          '- Date: $date, Score: $score/10, Emotions: ${emotions.isNotEmpty ? emotions : "none"}';
      if (note.isNotEmpty) {
        context += ', Note: $note';
      }
      context += '\n';

      docIds.add(doc.id);
    }

    return {'text': context, 'doc_ids': docIds};
  }

  /// Get nutrition-related context
  Future<Map<String, dynamic>> _getNutritionContext(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('meal_logs')
        .orderBy('at', descending: true)
        .limit(5)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'text': '', 'doc_ids': []};
    }

    String context = '\nRecent nutrition data:\n';
    List<String> docIds = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final total = (data['total'] as Map<String, dynamic>?) ?? {};
      final calories = total['kcal'] ?? 0;
      final date =
          (data['at'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '';

      context += '- Date: $date, Calories: $calories kcal\n';
      docIds.add(doc.id);
    }

    return {'text': context, 'doc_ids': docIds};
  }

  /// Get workout-related context
  Future<Map<String, dynamic>> _getWorkoutContext(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_sessions')
        .orderBy('started_at', descending: true)
        .limit(5)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'text': '', 'doc_ids': []};
    }

    String context = '\nRecent workout data:\n';
    List<String> docIds = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final status = data['status'] ?? '';
      final date = (data['started_at'] as Timestamp?)
              ?.toDate()
              .toString()
              .split(' ')[0] ??
          '';

      context += '- Date: $date, Status: $status\n';
      docIds.add(doc.id);
    }

    return {'text': context, 'doc_ids': docIds};
  }

  /// Get spiritual practice context
  Future<Map<String, dynamic>> _getSpiritualContext(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('practice_logs')
        .orderBy('at', descending: true)
        .limit(5)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'text': '', 'doc_ids': []};
    }

    String context = '\nRecent spiritual practice data:\n';
    List<String> docIds = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final duration = data['duration_min'] ?? 0;
      final date =
          (data['at'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '';

      context += '- Date: $date, Duration: $duration minutes\n';
      docIds.add(doc.id);
    }

    return {'text': context, 'doc_ids': docIds};
  }

  /// Get today's summary context
  Future<Map<String, dynamic>> _getTodayContext(String uid) async {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .doc(todayKey)
        .get();

    if (!doc.exists || doc.data() == null) {
      return {'text': '', 'doc_ids': []};
    }

    final data = doc.data() ?? {};
    String context = '\nToday\'s summary:\n';

    context += '- Calories: ${data['calories'] ?? 0}\n';
    context += '- Water: ${data['water_ml'] ?? 0} ml\n';
    context += '- Streak: ${data['streak'] ?? 0} days\n';

    final workouts = (data['workouts'] as Map<String, dynamic>?) ?? {};
    context +=
        '- Workouts: ${workouts['done'] ?? 0}/${workouts['target'] ?? 1}\n';

    final mood = (data['mood'] as Map<String, dynamic>?) ?? {};
    if (mood['latest'] != null) {
      context += '- Latest Mood: ${mood['latest']}/10\n';
    }

    final sadhana = (data['sadhana'] as Map<String, dynamic>?) ?? {};
    context +=
        '- Spiritual Practices: ${sadhana['done'] ?? 0}/${sadhana['target'] ?? 3}\n';

    return {
      'text': context,
      'doc_ids': [doc.id]
    };
  }
}

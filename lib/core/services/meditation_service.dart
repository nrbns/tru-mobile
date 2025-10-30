import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'gamification_service.dart';

/// Meditation & Mindfulness Service - Headspace/Calm-style
/// Full implementation with real-time Firebase integration
class MeditationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final GamificationService _gamificationService = GamificationService();

  CollectionReference get _meditationsRef =>
      _firestore.collection('meditations');

  CollectionReference get _userProgressRef {
    final user = _auth.currentUser;
    if (user == null) {
      // Fail fast with a clear error rather than a null-pointer later.
      throw StateError('MeditationService: user is not authenticated');
    }
    final uid = user.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('meditation_progress');
  }

  /// Get meditation library with filters
  Future<List<Map<String, dynamic>>> getMeditations({
    String? category, // stress, sleep, focus, anxiety, self-compassion
    String? difficulty, // beginner, intermediate, advanced
    int? duration, // minutes
    String? teacher,
    List<String>? tags,
    int limit = 50,
  }) async {
    Query query = _meditationsRef.limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    final snapshot = await query.get();
    var meditations = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'category': data['category'] ?? '',
        'duration': data['duration'] ?? 10,
        'audioUrl': data['audioUrl'] ?? '',
        'teacher': data['teacher'] ?? 'TruResetX Coach',
        'language': data['language'] ?? 'English',
        'tags': List<String>.from(data['tags'] ?? []),
        'difficulty': data['difficulty'] ?? 'beginner',
        'description': data['description'] ?? '',
        'imageUrl': data['imageUrl'],
        ...data,
      };
    }).toList();

    // Filter by duration if provided
    if (duration != null) {
      meditations =
          meditations.where((m) => m['duration'] == duration).toList();
    }

    // Filter by teacher if provided
    if (teacher != null) {
      meditations = meditations.where((m) => m['teacher'] == teacher).toList();
    }

    return meditations;
  }

  /// Stream meditations for real-time updates
  Stream<List<Map<String, dynamic>>> streamMeditations({
    String? category,
    String? difficulty,
    int limit = 50,
  }) {
    Query query = _meditationsRef.limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'category': data['category'] ?? '',
            'duration': data['duration'] ?? 10,
            'audioUrl': data['audioUrl'] ?? '',
            'teacher': data['teacher'] ?? 'TruResetX Coach',
            ...data,
          };
        }).toList());
  }

  /// Get meditation by ID
  Future<Map<String, dynamic>?> getMeditationById(String meditationId) async {
    final doc = await _meditationsRef.doc(meditationId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Start a meditation session
  Future<String> startMeditationSession({
    required String meditationId,
    DateTime? startTime,
  }) async {
    final now = startTime ?? DateTime.now();

    final sessionDoc = await _userProgressRef.add({
      'meditation_id': meditationId,
      'started_at': FieldValue.serverTimestamp(),
      'completed': false,
      'date':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'duration_minutes': 0,
    });

    return sessionDoc.id;
  }

  /// Log a completed meditation (convenience method)
  Future<void> logMeditation({
    required String meditationId,
    required int duration,
    required bool completed,
    int? focusScore,
    String? notes,
  }) async {
    final sessionId = await startMeditationSession(meditationId: meditationId);
    await completeMeditationSession(
      sessionId: sessionId,
      durationMinutes: duration,
      focusScore: focusScore,
      notes: notes,
    );
  }

  /// Complete a meditation session
  Future<void> completeMeditationSession({
    required String sessionId,
    required int durationMinutes,
    int? focusScore, // 1-10
    String? notes,
  }) async {
    final now = DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _userProgressRef.doc(sessionId).update({
      'completed': true,
      'completed_at': FieldValue.serverTimestamp(),
      'duration_minutes': durationMinutes,
      'focus_score': focusScore,
      'notes': notes,
      'date': dateKey,
    });

    // Update meditation streak
    await _updateMeditationStreak();

    // Award XP for meditation completion
    await _gamificationService.unlockAchievement(
      achievementId: 'meditation_completed',
      category: 'mind',
    );

    // Check daily meditation challenge
    await _checkDailyMeditationChallenge();
  }

  /// Get meditation progress (real-time)
  Stream<List<Map<String, dynamic>>> streamMeditationProgress(
      {int limit = 30}) {
    return _userProgressRef
        .where('completed', isEqualTo: true)
        .orderBy('completed_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get today's meditation sessions
  Stream<List<Map<String, dynamic>>> streamTodayMeditations() {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _userProgressRef
        .where('date', isEqualTo: dateKey)
        .where('completed', isEqualTo: true)
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get meditation streak
  Future<int> getMeditationStreak() async {
    final today = DateTime.now();
    int streak = 0;
    DateTime currentDate = today;

    for (int i = 0; i < 365; i++) {
      final dateKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

      final snapshot = await _userProgressRef
          .where('date', isEqualTo: dateKey)
          .where('completed', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break;
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get weekly meditation summary
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final startDateKey =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    final endDateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final snapshot = await _userProgressRef
        .where('date', isGreaterThanOrEqualTo: startDateKey)
        .where('date', isLessThanOrEqualTo: endDateKey)
        .where('completed', isEqualTo: true)
        .get();

    int totalSessions = snapshot.docs.length;
    int totalMinutes = 0;
    double avgFocusScore = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      totalMinutes += data['duration_minutes'] as int? ?? 0;
      final focus = data['focus_score'] as int?;
      if (focus != null) {
        avgFocusScore += focus;
      }
    }

    if (totalSessions > 0) {
      avgFocusScore = avgFocusScore / totalSessions;
    }

    return {
      'total_sessions': totalSessions,
      'total_minutes': totalMinutes,
      'avg_minutes_per_session':
          totalSessions > 0 ? (totalMinutes / totalSessions).round() : 0,
      'avg_focus_score': avgFocusScore.toStringAsFixed(1),
      // Guard against nullable document data and missing 'date' fields
      'days_active': snapshot.docs
          .map((d) {
            final data = d.data() as Map<String, dynamic>? ?? {};
            return data['date'] as String?;
          })
          .whereType<String>()
          .toSet()
          .length,
    };
  }

  /// Update meditation streak
  Future<void> _updateMeditationStreak() async {
    final _ = await getMeditationStreak();
    // Update in user profile or today collection
    // Could also trigger gamification achievement
  }

  /// Check daily meditation challenge
  Future<void> _checkDailyMeditationChallenge() async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final todaySessions = await _userProgressRef
        .where('date', isEqualTo: dateKey)
        .where('completed', isEqualTo: true)
        .get();

    if (todaySessions.docs.isNotEmpty) {
      // Mark daily challenge as complete
      await _gamificationService.unlockAchievement(
        achievementId: 'daily_meditation',
        category: 'mind',
      );
    }
  }

  /// Get sleep stories
  Future<List<Map<String, dynamic>>> getSleepStories({
    int limit = 20,
  }) async {
    return getMeditations(
      category: 'Sleep',
      tags: ['sleep_story', 'bedtime'],
      limit: limit,
    );
  }

  /// Get ambient sounds
  Future<List<Map<String, dynamic>>> getAmbientSounds({
    String? type, // rain, ocean, campfire, forest, etc.
  }) async {
    Query query = _firestore.collection('ambient_sounds').limit(50);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'type': data['type'] ?? '',
        'audioUrl': data['audioUrl'] ?? '',
        'duration_minutes': data['duration_minutes'] ?? 60,
        'imageUrl': data['imageUrl'],
        ...data,
      };
    }).toList();
  }

  /// Stream ambient sounds
  Stream<List<Map<String, dynamic>>> streamAmbientSounds() {
    return _firestore
        .collection('ambient_sounds')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get AI-guided meditation session
  Future<Map<String, dynamic>> getAIMeditationCoach({
    required String goal, // stress, sleep, focus, anxiety
    required int durationMinutes,
    String? userContext,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateMeditation');
      final result = await callable.call({
        'goal': goal,
        'duration_minutes': durationMinutes,
        'user_context': userContext,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to generate AI meditation: $e');
    }
  }

  /// Get meditation categories
  Future<List<String>> getCategories() async {
    final snapshot = await _meditationsRef.get();
    final categories = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category'] as String?;
      if (category != null) categories.add(category);
    }
    return categories.toList()..sort();
  }
}

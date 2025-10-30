import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'mood_service.dart';
import 'spiritual_service.dart';
// Note: NutritionService import not needed for meal planning

/// Meal Plan Service - AI-generated personalized meal plans
class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final MoodService _moodService = MoodService();
  final SpiritualService _spiritualService = SpiritualService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('MealPlanService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _mealPlansRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('meal_plans');
  }

  /// Generate weekly meal plan
  Future<Map<String, dynamic>> generateMealPlan({
    required int days,
    String? goal, // weight_loss, muscle_gain, maintenance, health
    int? targetCalories,
    List<String>? dietaryRestrictions,
    List<String>? preferences,
    bool includeSpiritualFasting = false,
  }) async {
    try {
      // Get user context
      final userContext = await _getUserContext();

      // Call Cloud Function
      final callable = _functions.httpsCallable('generateMealPlan');
      final result = await callable.call({
        'days': days,
        'goal': goal ?? 'maintenance',
        'target_calories': targetCalories ?? userContext['target_calories'],
        'dietary_restrictions': dietaryRestrictions ?? [],
        'preferences': preferences ?? [],
        'user_context': userContext,
        'include_spiritual_fasting': includeSpiritualFasting,
      });

      final plan = Map<String, dynamic>.from(result.data);

      // Save meal plan
      await _mealPlansRef.add({
        ...plan,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      return plan;
    } catch (e) {
      throw Exception('Failed to generate meal plan: $e');
    }
  }

  /// Get user context for meal planning
  Future<Map<String, dynamic>> _getUserContext() async {
    final uid = _requireUid();

    // Get user doc
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};

    // Get recent mood
    final recentMoods = await _moodService.getMoodLogs(limit: 7);
    final avgMood = recentMoods.isNotEmpty
        ? recentMoods.map((m) => m.score).reduce((a, b) => a + b) /
            recentMoods.length
        : 5.0;

    // Get spiritual practices
    final spiritualStreak = await _spiritualService.getStreakDays();

    // Get recent meal patterns
    final mealLogsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('meal_logs')
        .orderBy('at', descending: true)
        .limit(10)
        .get();

    final recentMeals = mealLogsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'food': data['food_name'] ?? '',
        'kcal': data['kcal'] ?? 0,
        'time': data['at'],
      };
    }).toList();

    // Get macro targets
    final macroTargets =
        (userData['macro_targets'] as Map<String, dynamic>?) ?? {};

    return {
      'user_id': uid,
      'height_cm': userData['height_cm'],
      'weight_kg': userData['weight_kg'],
      'goals': userData['goals'] ?? [],
      'traditions': userData['traditions'] ?? [],
      'target_calories': macroTargets['calories'] ?? 2000,
      'target_protein': macroTargets['protein'] ?? 150,
      'target_carbs': macroTargets['carbs'] ?? 200,
      'target_fat': macroTargets['fat'] ?? 65,
      'avg_mood_7d': avgMood,
      'spiritual_streak': spiritualStreak,
      'recent_meals': recentMeals,
      'dietary_restrictions': userData['dietary_restrictions'] ?? [],
      'food_preferences': userData['food_preferences'] ?? [],
    };
  }

  /// Get active meal plan
  Stream<Map<String, dynamic>?> getActiveMealPlan() {
    return _mealPlansRef
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final map = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...map,
      };
    });
  }

  /// Get meal plan history
  Future<List<Map<String, dynamic>>> getMealPlanHistory(
      {int limit = 10}) async {
    final snapshot = await _mealPlansRef
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Mark meal as completed in plan
  Future<void> completeMealFromPlan({
    required String planId,
    required String day,
    required String mealType, // breakfast, lunch, dinner, snack
  }) async {
    await _mealPlansRef.doc(planId).update({
      'completed_meals': FieldValue.arrayUnion(['$day:$mealType']),
    });
  }

  /// Get today's meals from active plan
  Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final activePlan = await _mealPlansRef
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    if (activePlan.docs.isEmpty) return [];

    final planData =
        activePlan.docs.first.data() as Map<String, dynamic>? ?? {};
    final meals = (planData['meals'] as Map<String, dynamic>?) ?? {};

    // Get today's date key
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final raw = meals[todayKey] as List<dynamic>? ?? [];
    // Ensure we return a List<Map<String, dynamic>> as declared
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Update meal plan with user feedback
  Future<void> updateMealPlanFeedback({
    required String planId,
    required String mealId,
    bool? liked,
    String? feedback,
  }) async {
    await _mealPlansRef.doc(planId).update({
      'feedback.$mealId': {
        'liked': liked,
        'feedback': feedback,
        'updated_at': FieldValue.serverTimestamp(),
      },
    });
  }
}

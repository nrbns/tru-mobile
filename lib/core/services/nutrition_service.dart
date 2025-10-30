import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'today_service.dart';
import 'food_database_service.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TodayService _todayService = TodayService();
  final FoodDatabaseService _foodDatabase = FoodDatabaseService();

  CollectionReference get _mealLogsRef {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('NutritionService: no authenticated user');
    }
    final uid = currentUser.uid;
    return _firestore.collection('users').doc(uid).collection('meal_logs');
  }

  CollectionReference get _foodsRef => _firestore.collection('foods');

  /// Scan barcode to get food information (Spoonacular-like)
  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    try {
      // Use food database service (calls Cloud Function with Spoonacular API)
      return await _foodDatabase.scanBarcode(barcode);
    } catch (e) {
      throw Exception('Failed to scan barcode: $e');
    }
  }

  /// Search foods by name (HealthifyMe/Spoonacular-like search)
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      return await _foodDatabase.searchFoods(query);
    } catch (e) {
      throw Exception('Failed to search foods: $e');
    }
  }

  /// Get food details with nutrition information
  Future<Map<String, dynamic>> getFoodDetails(int foodId) async {
    try {
      return await _foodDatabase.getFoodDetails(foodId);
    } catch (e) {
      throw Exception('Failed to get food details: $e');
    }
  }

  /// Parse food from image (OCR + AI recognition)
  Future<Map<String, dynamic>> parseFoodFromImage(String imageUrl) async {
    try {
      return await _foodDatabase.parseFoodFromImage(imageUrl);
    } catch (e) {
      throw Exception('Failed to parse food from image: $e');
    }
  }

  Future<void> logMeal({
    required List<Map<String, dynamic>> items,
    String? note,
    String? photoUrl,
  }) async {
    // Calculate total calories and macros
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (var item in items) {
      totalCalories += (item['kcal'] as int? ?? 0);
      totalProtein += (item['protein'] as int? ?? 0);
      totalCarbs += (item['carbs'] as int? ?? 0);
      totalFat += (item['fat'] as int? ?? 0);
    }

    await _mealLogsRef.add({
      'at': FieldValue.serverTimestamp(),
      'items': items,
      'note': note,
      'photo_url': photoUrl,
      'total': {
        'kcal': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
      },
    });

    // Update today's calories
    await _todayService.updateCalories(totalCalories);
    await _todayService.callAggregateToday();
  }

  Stream<List<Map<String, dynamic>>> streamMealLogs({int limit = 50}) {
    return _mealLogsRef
        .orderBy('at', descending: true)
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

  Future<Map<String, dynamic>?> getFood(String foodId) async {
    final doc = await _foodsRef.doc(foodId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  Future<List<Map<String, dynamic>>> searchLocalFoods(String query) async {
    final snapshot = await _foodsRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Future<void> addCustomFood(Map<String, dynamic> foodData) async {
    await _foodsRef.add({
      ...foodData,
      'source': 'user',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Stream today's meals (real-time)
  Stream<List<Map<String, dynamic>>> streamMeals({int limit = 10}) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _mealLogsRef
        .where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('at', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('at', descending: true)
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

  /// Get today's total calories
  Future<int> getTodayCalories() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _mealLogsRef
        .where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('at', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    int totalCalories = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final total = (data['total'] as Map<String, dynamic>?) ?? {};
      totalCalories += (total['kcal'] as int? ?? 0);
    }

    return totalCalories;
  }

  /// Get weekly nutrition summary
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekStartTimestamp = Timestamp.fromDate(
      DateTime(weekStart.year, weekStart.month, weekStart.day),
    );
    final weekEndTimestamp = Timestamp.fromDate(today);

    final snapshot = await _mealLogsRef
        .where('at', isGreaterThanOrEqualTo: weekStartTimestamp)
        .where('at', isLessThanOrEqualTo: weekEndTimestamp)
        .get();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int mealCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final total = (data['total'] as Map<String, dynamic>?) ?? {};
      if (total.isNotEmpty) {
        totalCalories += total['kcal'] as int? ?? 0;
        totalProtein += total['protein'] as int? ?? 0;
        totalCarbs += total['carbs'] as int? ?? 0;
        totalFat += total['fat'] as int? ?? 0;
        mealCount++;
      }
    }

    return {
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'meal_count': mealCount,
      'avg_calories_per_day': (totalCalories / 7).round(),
    };
  }
}

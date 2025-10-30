import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'nutrition_service.dart';

/// Service for food image recognition (HealthifyMe Snap feature)
/// Uses Cloud Vision API via Cloud Functions
class FoodImageRecognitionService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final ImagePicker _imagePicker = ImagePicker();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('FoodImageRecognitionService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Capture image from camera or gallery
  Future<File?> pickImage({bool fromCamera = true}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Upload image to Firebase Storage and get recognition result
  Future<Map<String, dynamic>> recognizeFood(File imageFile) async {
    try {
      // Upload image
      final uid = _requireUid();
      final fileName =
          'food_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      // Call Cloud Function for recognition
      final callable = _functions.httpsCallable('recognizeFood');
      final result = await callable.call({
        'image_url': downloadUrl,
        'user_id': uid,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to recognize food: $e');
    }
  }

  /// Recognize multiple foods in image (for complex meals)
  Future<List<Map<String, dynamic>>> recognizeMeal(File imageFile) async {
    try {
      final uid = _requireUid();
      final fileName =
          'food_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      final callable = _functions.httpsCallable('recognizeFood');
      final result = await callable.call({
        'image_url': downloadUrl,
        'user_id': uid,
      });

      final data = Map<String, dynamic>.from(result.data);
      final foods = data['foods'] as List? ?? [];
      return foods.map((f) => Map<String, dynamic>.from(f)).toList();
    } catch (e) {
      throw Exception('Failed to recognize meal: $e');
    }
  }

  /// Get nutrition data for recognized food
  Future<Map<String, dynamic>> getNutritionForRecognizedFood({
    required String foodName,
    String? portion,
  }) async {
    try {
      // Use NutritionService to search for food via Spoonacular
      try {
        final nutritionService = NutritionService();
        final searchResults = await nutritionService.searchFoods(foodName);
        if (searchResults.isNotEmpty) {
          final firstResult = searchResults.first;
          return {
            'name': foodName,
            'portion': portion ?? '1 serving',
            'kcal': firstResult['nutrition']?['calories'] ?? 0,
            'protein': firstResult['nutrition']?['protein'] ?? 0,
            'carbs': firstResult['nutrition']?['carbs'] ?? 0,
            'fat': firstResult['nutrition']?['fat'] ?? 0,
            'food_id': firstResult['id'],
            'needs_verification': true,
          };
        }
      } catch (e) {
        print('Failed to search nutrition: $e');
      }

      // Fallback if search fails
      return {
        'name': foodName,
        'portion': portion ?? '1 serving',
        'kcal': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'needs_verification': true,
      };
    } catch (e) {
      throw Exception('Failed to get nutrition: $e');
    }
  }

  /// Save recognized meal to Firestore with real-time updates
  Future<String> saveRecognizedMeal({
    required List<Map<String, dynamic>> foods,
    required String imageUrl,
    DateTime? timestamp,
  }) async {
    try {
      final uid = _requireUid();
      final firestore = FirebaseFirestore.instance;
      final now = timestamp ?? DateTime.now();

      // Calculate total nutrition
      int totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final food in foods) {
        totalCalories += (food['kcal_estimate'] as num?)?.toInt() ?? 0;
        totalProtein += (food['protein'] as num?)?.toDouble() ?? 0;
        totalCarbs += (food['carbs'] as num?)?.toDouble() ?? 0;
        totalFat += (food['fat'] as num?)?.toDouble() ?? 0;
      }

      // Save meal to Firestore
      final mealDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('snap_meals')
          .add({
        'image_url': imageUrl,
        'foods': foods,
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'recognized_at': FieldValue.serverTimestamp(),
        'verified': false, // User can verify after
        'timestamp': Timestamp.fromDate(now),
      });

      // Also log to nutrition service for today's tracking
      final nutritionService = NutritionService();
      final mealItems = foods
          .map((food) => {
                'food_id': food['id']?.toString(),
                'food_name': food['name'] ?? 'Food',
                'quantity': 1,
                'unit': food['portion'] ?? 'serving',
                'kcal': (food['kcal_estimate'] as num?)?.toInt() ?? 0,
                'protein': (food['protein'] as num?)?.toInt() ?? 0,
                'carbs': (food['carbs'] as num?)?.toInt() ?? 0,
                'fat': (food['fat'] as num?)?.toInt() ?? 0,
              })
          .toList();

      await nutritionService.logMeal(
        items: mealItems,
        photoUrl: imageUrl,
      );

      return mealDoc.id;
    } catch (e) {
      throw Exception('Failed to save recognized meal: $e');
    }
  }

  /// Stream recognized meals for real-time updates
  Stream<List<Map<String, dynamic>>> streamRecognizedMeals({int limit = 30}) {
    final uid = _requireUid();
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('users')
        .doc(uid)
        .collection('snap_meals')
        .orderBy('recognized_at', descending: true)
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
}

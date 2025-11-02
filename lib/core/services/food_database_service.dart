import 'package:cloud_functions/cloud_functions.dart';

/// Food Database Service - Integration with Spoonacular API
/// Similar to HealthifyMe/Spoonacular food tracking
class FoodDatabaseService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  /// Search foods by name (like Spoonacular)
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final callable = _functions.httpsCallable('search-foods');
      final result = await callable.call({'query': query});
      return List<Map<String, dynamic>>.from(result.data as List);
    } catch (e) {
      throw Exception('Failed to search foods: $e');
    }
  }

  /// Get food details by ID
  Future<Map<String, dynamic>> getFoodDetails(int foodId) async {
    try {
      final callable = _functions.httpsCallable('get-food-details');
      final result = await callable.call({'food_id': foodId});
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to get food details: $e');
    }
  }

  /// Scan barcode to get food information
  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    try {
      final callable = _functions.httpsCallable('scan-barcode');
      final result = await callable.call({'barcode': barcode});
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to scan barcode: $e');
    }
  }

  /// Get nutrition information for a food item
  Future<Map<String, dynamic>> getNutritionInfo({
    required String foodName,
    double? amount,
    String? unit,
  }) async {
    try {
      final callable = _functions.httpsCallable('get-nutrition-info');
      final result = await callable.call({
        'food_name': foodName,
        'amount': amount,
        'unit': unit ?? 'serving',
      });
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to get nutrition info: $e');
    }
  }

  /// Get similar foods (recommendations)
  Future<List<Map<String, dynamic>>> getSimilarFoods(int foodId) async {
    try {
      final callable = _functions.httpsCallable('get-similar-foods');
      final result = await callable.call({'food_id': foodId});
      return List<Map<String, dynamic>>.from(result.data as List);
    } catch (e) {
      throw Exception('Failed to get similar foods: $e');
    }
  }

  /// Parse food from image (OCR + AI)
  Future<Map<String, dynamic>> parseFoodFromImage(String imageUrl) async {
    try {
      final callable = _functions.httpsCallable('parse-food-image');
      final result = await callable.call({'image_url': imageUrl});
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('Failed to parse food from image: $e');
    }
  }
}

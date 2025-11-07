import 'package:uuid/uuid.dart';

/// Food Log model for TruResetX v1.0
class FoodLog {
  FoodLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    this.imageUrl,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.servingSize,
    this.confidenceScore,
    required this.createdAt,
  });

  /// Create a new food log
  factory FoodLog.create({
    required String userId,
    DateTime? date,
    required String mealType,
    required String foodName,
    String? imageUrl,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    String? servingSize,
    double? confidenceScore,
  }) {
    return FoodLog(
      id: const Uuid().v4(),
      userId: userId,
      date: date ?? DateTime.now(),
      mealType: mealType,
      foodName: foodName,
      imageUrl: imageUrl,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      servingSize: servingSize,
      confidenceScore: confidenceScore,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      mealType: json['meal_type'],
      foodName: json['food_name'],
      imageUrl: json['image_url'],
      calories: json['calories'],
      protein: json['protein']?.toDouble(),
      carbs: json['carbs']?.toDouble(),
      fat: json['fat']?.toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      servingSize: json['serving_size'],
      confidenceScore: json['confidence_score']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String userId;
  final DateTime date;
  final String mealType;
  final String foodName;
  final String? imageUrl;
  final int? calories;
  final double? protein; // in grams
  final double? carbs; // in grams
  final double? fat; // in grams
  final double? fiber; // in grams
  final double? sugar; // in grams
  final double? sodium; // in mg
  final String? servingSize;
  final double? confidenceScore; // AI confidence 0.00 to 1.00
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'meal_type': mealType,
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'serving_size': servingSize,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  FoodLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? mealType,
    String? foodName,
    String? imageUrl,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    String? servingSize,
    double? confidenceScore,
    DateTime? createdAt,
  }) {
    return FoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      servingSize: servingSize ?? this.servingSize,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get total calories
  int get totalCalories => calories ?? 0;

  /// Get total protein in grams
  double get totalProtein => protein ?? 0.0;

  /// Get total carbs in grams
  double get totalCarbs => carbs ?? 0.0;

  /// Get total fat in grams
  double get totalFat => fat ?? 0.0;

  /// Get total fiber in grams
  double get totalFiber => fiber ?? 0.0;

  /// Get total sugar in grams
  double get totalSugar => sugar ?? 0.0;

  /// Get total sodium in mg
  double get totalSodium => sodium ?? 0.0;

  /// Get macro percentages
  Map<String, double> get macroPercentages {
    final totalCalories = this.totalCalories;
    if (totalCalories == 0) return {'protein': 0, 'carbs': 0, 'fat': 0};

    return {
      'protein': (totalProtein * 4) / totalCalories * 100,
      'carbs': (totalCarbs * 4) / totalCalories * 100,
      'fat': (totalFat * 9) / totalCalories * 100,
    };
  }

  /// Get meal type display text
  String get mealTypeDisplayText {
    switch (mealType) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return mealType;
    }
  }

  /// Get confidence score display text
  String get confidenceScoreDisplayText {
    if (confidenceScore == null) return 'Unknown';
    return '${(confidenceScore! * 100).toInt()}%';
  }

  /// Check if food has complete nutrition data
  bool get hasCompleteNutrition =>
      calories != null && protein != null && carbs != null && fat != null;

  /// Check if food was AI-scanned
  bool get isAIScanned => confidenceScore != null;

  /// Get nutrition quality score (0-100)
  int get nutritionQualityScore {
    if (!hasCompleteNutrition) return 0;

    int score = 0;

    // Protein score (0-30 points)
    if (totalProtein > 0) score += 30;

    // Fiber score (0-20 points)
    if (totalFiber > 0) {
      score += 20;
    }

    // Low sugar score (0-20 points)
    if (totalSugar <= 10) {
      score += 20;
    } else if (totalSugar <= 20) {
      score += 10;
    }

    // Low sodium score (0-15 points)
    if (totalSodium <= 200) {
      score += 15;
    } else if (totalSodium <= 400) {
      score += 10;
    } else if (totalSodium <= 600) {
      score += 5;
    }

    // Balanced macros (0-15 points)
    final macros = macroPercentages;
    if (macros['protein']! >= 15 &&
        macros['protein']! <= 35 &&
        macros['carbs']! >= 40 &&
        macros['carbs']! <= 65 &&
        macros['fat']! >= 15 &&
        macros['fat']! <= 35) {
      score += 15;
    }

    return score;
  }

  /// Get nutrition quality level
  String get nutritionQualityLevel {
    final score = nutritionQualityScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  String toString() {
    return 'FoodLog(id: $id, foodName: $foodName, mealType: $mealType, calories: $totalCalories, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

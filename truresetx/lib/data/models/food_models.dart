import 'package:json_annotation/json_annotation.dart';

part 'food_models.g.dart';

@JsonSerializable()
class FoodCatalog {
  FoodCatalog({
    required this.id,
    required this.source,
    this.externalId,
    required this.name,
    this.brand,
    this.servingQty,
    this.servingUnit,
    required this.nutrients,
    this.labels,
    this.lang = 'en',
    this.updatedAt,
  });

  factory FoodCatalog.fromJson(Map<String, dynamic> json) => _$FoodCatalogFromJson(json);

  final int id;
  final String source; // 'USDA', 'OFF', 'MANUAL'
  final String? externalId;
  final String name;
  final String? brand;
  final double? servingQty;
  final String? servingUnit;
  final Map<String, dynamic> nutrients;
  final Map<String, dynamic>? labels;
  final String lang;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$FoodCatalogToJson(this);

  /// Get calories from nutrients
  double get calories => (nutrients['calories'] as num?)?.toDouble() ?? 0.0;

  /// Get protein from nutrients
  double get protein => (nutrients['protein_g'] as num?)?.toDouble() ?? 0.0;

  /// Get carbs from nutrients
  double get carbs => (nutrients['carbs_g'] as num?)?.toDouble() ?? 0.0;

  /// Get fat from nutrients
  double get fat => (nutrients['fat_g'] as num?)?.toDouble() ?? 0.0;

  /// Get fiber from nutrients
  double get fiber => (nutrients['fiber_g'] as num?)?.toDouble() ?? 0.0;

  /// Get sugar from nutrients
  double get sugar => (nutrients['sugar_g'] as num?)?.toDouble() ?? 0.0;

  /// Get sodium from nutrients
  double get sodium => (nutrients['sodium_mg'] as num?)?.toDouble() ?? 0.0;

  /// Get formatted serving size
  String get formattedServingSize {
    if (servingQty == null || servingUnit == null) return '1 serving';
    return '${servingQty!.toStringAsFixed(servingQty! % 1 == 0 ? 0 : 1)} $servingUnit';
  }

  /// Get display name with brand
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand $name';
    }
    return name;
  }
}

@JsonSerializable()
class FoodLog {
  FoodLog({
    required this.id,
    required this.userId,
    required this.loggedAt,
    this.foodId,
    this.source, // 'SCAN', 'BARCODE', 'MANUAL'
    this.imageUrl,
    required this.quantity,
    this.overrides,
    this.totals,
    this.createdAt,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) => _$FoodLogFromJson(json);

  final int id;
  final String userId;
  final DateTime loggedAt;
  final int? foodId;
  final String? source;
  final String? imageUrl;
  final double quantity;
  final Map<String, dynamic>? overrides;
  final Map<String, dynamic>? totals;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$FoodLogToJson(this);

  /// Get total calories for this log entry
  double get totalCalories => (totals?['calories'] as num?)?.toDouble() ?? 0.0;

  /// Get total protein for this log entry
  double get totalProtein => (totals?['protein_g'] as num?)?.toDouble() ?? 0.0;

  /// Get total carbs for this log entry
  double get totalCarbs => (totals?['carbs_g'] as num?)?.toDouble() ?? 0.0;

  /// Get total fat for this log entry
  double get totalFat => (totals?['fat_g'] as num?)?.toDouble() ?? 0.0;
}

@JsonSerializable()
class DailyNutrition {
  DailyNutrition({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalSugar,
    required this.totalSodium,
    required this.foodLogs,
    required this.goals,
    this.insights,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => _$DailyNutritionFromJson(json);

  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  final List<FoodLog> foodLogs;
  final Map<String, double> goals;
  final Map<String, dynamic>? insights;

  Map<String, dynamic> toJson() => _$DailyNutritionToJson(this);

  /// Get calories progress (0.0 to 1.0)
  double get caloriesProgress {
    final goal = goals['calories'] ?? 2000.0;
    return (totalCalories / goal).clamp(0.0, 1.0);
  }

  /// Get protein progress (0.0 to 1.0)
  double get proteinProgress {
    final goal = goals['protein_g'] ?? 150.0;
    return (totalProtein / goal).clamp(0.0, 1.0);
  }

  /// Get carbs progress (0.0 to 1.0)
  double get carbsProgress {
    final goal = goals['carbs_g'] ?? 250.0;
    return (totalCarbs / goal).clamp(0.0, 1.0);
  }

  /// Get fat progress (0.0 to 1.0)
  double get fatProgress {
    final goal = goals['fat_g'] ?? 65.0;
    return (totalFat / goal).clamp(0.0, 1.0);
  }

  /// Get overall nutrition score (0-100)
  int get nutritionScore {
    int score = 0;
    
    // Calories score (25 points max)
    if (caloriesProgress >= 0.8 && caloriesProgress <= 1.2) {
      score += 25;
    } else if (caloriesProgress >= 0.6 && caloriesProgress <= 1.4) {
      score += 20;
    } else if (caloriesProgress >= 0.4 && caloriesProgress <= 1.6) {
      score += 15;
    } else {
      score += 10;
    }
    
    // Protein score (25 points max)
    if (proteinProgress >= 0.8) {
      score += 25;
    } else if (proteinProgress >= 0.6) {
      score += 20;
    } else if (proteinProgress >= 0.4) {
      score += 15;
    } else {
      score += 10;
    }
    
    // Carbs score (25 points max)
    if (carbsProgress >= 0.8 && carbsProgress <= 1.2) {
      score += 25;
    } else if (carbsProgress >= 0.6 && carbsProgress <= 1.4) {
      score += 20;
    } else if (carbsProgress >= 0.4 && carbsProgress <= 1.6) {
      score += 15;
    } else {
      score += 10;
    }
    
    // Fat score (25 points max)
    if (fatProgress >= 0.8 && fatProgress <= 1.2) {
      score += 25;
    } else if (fatProgress >= 0.6 && fatProgress <= 1.4) {
      score += 20;
    } else if (fatProgress >= 0.4 && fatProgress <= 1.6) {
      score += 15;
    } else {
      score += 10;
    }
    
    return score;
  }

  /// Get nutrition insights
  List<String> get nutritionInsights {
    final insights = <String>[];
    
    if (caloriesProgress < 0.8) {
      insights.add('You need more calories to meet your daily goal.');
    } else if (caloriesProgress > 1.2) {
      insights.add('You\'ve exceeded your calorie goal for today.');
    }
    
    if (proteinProgress < 0.8) {
      insights.add('Consider adding more protein to your meals.');
    }
    
    if (totalFiber < 25) {
      insights.add('Add more fiber-rich foods like fruits and vegetables.');
    }
    
    if (totalSodium > 2300) {
      insights.add('Consider reducing sodium intake for better health.');
    }
    
    if (insights.isEmpty) {
      insights.add('Great job! Your nutrition is well-balanced today.');
    }
    
    return insights;
  }
}

@JsonSerializable()
class FoodSearchResult {
  FoodSearchResult({
    required this.foods,
    required this.totalCount,
    this.source,
    this.query,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) => _$FoodSearchResultFromJson(json);

  final List<FoodCatalog> foods;
  final int totalCount;
  final String? source; // 'local', 'USDA', 'OFF'
  final String? query;

  Map<String, dynamic> toJson() => _$FoodSearchResultToJson(this);
}

@JsonSerializable()
class FoodScanResult {
  FoodScanResult({
    required this.success,
    this.food,
    this.confidence,
    this.message,
    this.barcodeData,
  });

  factory FoodScanResult.fromJson(Map<String, dynamic> json) => _$FoodScanResultFromJson(json);

  final bool success;
  final FoodCatalog? food;
  final double? confidence;
  final String? message;
  final Map<String, dynamic>? barcodeData;

  Map<String, dynamic> toJson() => _$FoodScanResultToJson(this);
}

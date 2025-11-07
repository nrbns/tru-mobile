// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodCatalog _$FoodCatalogFromJson(Map<String, dynamic> json) => FoodCatalog(
      id: (json['id'] as num).toInt(),
      source: json['source'] as String,
      externalId: json['externalId'] as String?,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      servingQty: (json['servingQty'] as num?)?.toDouble(),
      servingUnit: json['servingUnit'] as String?,
      nutrients: json['nutrients'] as Map<String, dynamic>,
      labels: json['labels'] as Map<String, dynamic>?,
      lang: json['lang'] as String? ?? 'en',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FoodCatalogToJson(FoodCatalog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'externalId': instance.externalId,
      'name': instance.name,
      'brand': instance.brand,
      'servingQty': instance.servingQty,
      'servingUnit': instance.servingUnit,
      'nutrients': instance.nutrients,
      'labels': instance.labels,
      'lang': instance.lang,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FoodLog _$FoodLogFromJson(Map<String, dynamic> json) => FoodLog(
      id: (json['id'] as num).toInt(),
      userId: json['userId'] as String,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      foodId: (json['foodId'] as num?)?.toInt(),
      source: json['source'] as String?,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      overrides: json['overrides'] as Map<String, dynamic>?,
      totals: json['totals'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FoodLogToJson(FoodLog instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'loggedAt': instance.loggedAt.toIso8601String(),
      'foodId': instance.foodId,
      'source': instance.source,
      'imageUrl': instance.imageUrl,
      'quantity': instance.quantity,
      'overrides': instance.overrides,
      'totals': instance.totals,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

DailyNutrition _$DailyNutritionFromJson(Map<String, dynamic> json) =>
    DailyNutrition(
      date: DateTime.parse(json['date'] as String),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      totalFiber: (json['totalFiber'] as num).toDouble(),
      totalSugar: (json['totalSugar'] as num).toDouble(),
      totalSodium: (json['totalSodium'] as num).toDouble(),
      foodLogs: (json['foodLogs'] as List<dynamic>)
          .map((e) => FoodLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      insights: json['insights'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DailyNutritionToJson(DailyNutrition instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalCalories': instance.totalCalories,
      'totalProtein': instance.totalProtein,
      'totalCarbs': instance.totalCarbs,
      'totalFat': instance.totalFat,
      'totalFiber': instance.totalFiber,
      'totalSugar': instance.totalSugar,
      'totalSodium': instance.totalSodium,
      'foodLogs': instance.foodLogs,
      'goals': instance.goals,
      'insights': instance.insights,
    };

FoodSearchResult _$FoodSearchResultFromJson(Map<String, dynamic> json) =>
    FoodSearchResult(
      foods: (json['foods'] as List<dynamic>)
          .map((e) => FoodCatalog.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      source: json['source'] as String?,
      query: json['query'] as String?,
    );

Map<String, dynamic> _$FoodSearchResultToJson(FoodSearchResult instance) =>
    <String, dynamic>{
      'foods': instance.foods,
      'totalCount': instance.totalCount,
      'source': instance.source,
      'query': instance.query,
    };

FoodScanResult _$FoodScanResultFromJson(Map<String, dynamic> json) =>
    FoodScanResult(
      success: json['success'] as bool,
      food: json['food'] == null
          ? null
          : FoodCatalog.fromJson(json['food'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num?)?.toDouble(),
      message: json['message'] as String?,
      barcodeData: json['barcodeData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FoodScanResultToJson(FoodScanResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'food': instance.food,
      'confidence': instance.confidence,
      'message': instance.message,
      'barcodeData': instance.barcodeData,
    };

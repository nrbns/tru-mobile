// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WellnessList _$WellnessListFromJson(Map<String, dynamic> json) => WellnessList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$ListCategoryEnumMap, json['category']),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$WellnessListToJson(WellnessList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$ListCategoryEnumMap[instance.category]!,
      'items': instance.items,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'icon': instance.icon,
      'color': instance.color,
      'isArchived': instance.isArchived,
    };

const _$ListCategoryEnumMap = {
  ListCategory.fitness: 'fitness',
  ListCategory.nutrition: 'nutrition',
  ListCategory.mentalHealth: 'mental_health',
  ListCategory.spiritual: 'spiritual',
  ListCategory.habits: 'habits',
  ListCategory.goals: 'goals',
  ListCategory.general: 'general',
};

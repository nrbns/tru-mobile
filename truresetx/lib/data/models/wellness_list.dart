import 'package:json_annotation/json_annotation.dart';
import 'list_item.dart';

part 'wellness_list.g.dart';

enum ListCategory {
  @JsonValue('fitness')
  fitness,
  @JsonValue('nutrition')
  nutrition,
  @JsonValue('mental_health')
  mentalHealth,
  @JsonValue('spiritual')
  spiritual,
  @JsonValue('habits')
  habits,
  @JsonValue('goals')
  goals,
  @JsonValue('general')
  general,
}

@JsonSerializable()
class WellnessList {

  const WellnessList({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    this.color,
    this.isArchived = false,
  });

  factory WellnessList.fromJson(Map<String, dynamic> json) => _$WellnessListFromJson(json);
  final String id;
  final String name;
  final String? description;
  final ListCategory category;
  final List<ListItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? icon;
  final String? color;
  final bool isArchived;

  WellnessList copyWith({
    String? id,
    String? name,
    String? description,
    ListCategory? category,
    List<ListItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? icon,
    String? color,
    bool? isArchived,
  }) {
    return WellnessList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  int get completedCount => items.where((item) => item.isCompleted).length;
  int get totalCount => items.length;
  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0.0;
  Map<String, dynamic> toJson() => _$WellnessListToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WellnessList{id: $id, name: $name, category: $category, items: ${items.length}}';
  }
}

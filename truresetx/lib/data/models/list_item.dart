import 'package:json_annotation/json_annotation.dart';

part 'list_item.g.dart';

enum ListItemType {
  @JsonValue('task')
  task,
  @JsonValue('habit')
  habit,
  @JsonValue('goal')
  goal,
  @JsonValue('note')
  note,
  @JsonValue('reminder')
  reminder,
}

@JsonSerializable()
class ListItem {

  const ListItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.priority = 3,
    this.tags = const [],
    this.metadata,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);
  final String id;
  final String title;
  final String? description;
  final ListItemType type;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int priority; // 1-5, 5 being highest
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  ListItem copyWith({
    String? id,
    String? title,
    String? description,
    ListItemType? type,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return ListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
  Map<String, dynamic> toJson() => _$ListItemToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ListItem{id: $id, title: $title, type: $type, isCompleted: $isCompleted}';
  }
}

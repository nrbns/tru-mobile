import 'package:cloud_firestore/cloud_firestore.dart';

class AppItem {
  final String id;
  final String name;
  final String type;
  final List<String> focus;
  final String description;
  final double rating;
  final String iconUrl;

  AppItem({
    required this.id,
    required this.name,
    required this.type,
    required this.focus,
    required this.description,
    required this.rating,
    required this.iconUrl,
  });

  factory AppItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppItem(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      focus: List<String>.from(data['focus'] ?? []),
      description: data['description'] ?? '',
      rating:
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
      iconUrl: data['icon_url'] ?? '',
    );
  }
}

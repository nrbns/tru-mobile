import 'package:cloud_firestore/cloud_firestore.dart';

/// Small helpers to safely extract data from Firestore snapshots and documents.
/// Keeps callers concise and avoids repeated `as Map<String, dynamic>? ?? {}` patterns.

Map<String, dynamic> safeDocData(DocumentSnapshot doc) {
  final data = doc.data();
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{};
}

Map<String, dynamic> safeQueryDocData(QueryDocumentSnapshot doc) {
  final data = doc.data();
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{};
}

T? valueOrNull<T>(DocumentSnapshot doc, String key) {
  final data = safeDocData(doc);
  final v = data[key];
  return v is T ? v : null;
}

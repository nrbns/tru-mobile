import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight wrapper over Firestore snapshot streams to centralize
/// error handling and make real-time wiring easier in UI code.
class RealtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream a collection path with optional query builder.
  /// Example:
  ///   streamCollection('users', (q) => q.where('active', isEqualTo: true))
  Stream<List<QueryDocumentSnapshot>> streamCollection(
    String path, {
    Query Function(Query)? queryBuilder,
  }) {
    Query base = _firestore.collection(path);
    if (queryBuilder != null) base = queryBuilder(base);
    return base.snapshots().map((snap) => snap.docs);
  }

  /// Stream a document at `path` (e.g. 'users/<uid>'). Emits DocumentSnapshot.
  Stream<DocumentSnapshot> streamDocument(String path) {
    return _firestore.doc(path).snapshots();
  }

  /// Convenience: read a document once with safe cast
  Future<Map<String, dynamic>> readDocumentOnce(String path) async {
    final doc = await _firestore.doc(path).get();
    final data = doc.data();
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }
}

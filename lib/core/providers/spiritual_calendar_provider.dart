import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the current user's "today/calendar" document, or null when unauthenticated.
final userTodayCalendarStreamProvider =
    StreamProvider<DocumentSnapshot?>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final uid = auth.currentUser?.uid;
  if (uid == null) {
    // Not signed-in: emit a single null value so consumers handle unauthenticated state.
    return Stream.value(null);
  }
  return firestore
      .collection('users')
      .doc(uid)
      .collection('today')
      .doc('calendar')
      .snapshots();
});

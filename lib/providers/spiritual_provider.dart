import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_item.dart';

final spiritualAppsProvider = StreamProvider.autoDispose<List<AppItem>>((ref) {
  final col = FirebaseFirestore.instance.collection('apps');
  final controller = col
      .orderBy('rating', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => AppItem.fromDoc(d)).toList());
  return controller;
});

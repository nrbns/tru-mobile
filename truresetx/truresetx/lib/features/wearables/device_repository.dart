import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple DeviceRepository to register devices and write telemetry into Firestore
/// under `/users/{uid}/devices/{deviceId}` and `/users/{uid}/telemetry`.
class DeviceRepository {
  final _firestore = FirebaseFirestore.instance;

  DeviceRepository._();
  static DeviceRepository? _instance;
  static DeviceRepository get instance => _instance ??= DeviceRepository._();

  Future<void> registerDevice(
      String uid, String deviceId, Map<String, dynamic> info) async {
    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(deviceId);
    await doc.set({
      ...info,
      'deviceId': deviceId,
      'pairedAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> writeTelemetryBatch(
      String uid, List<Map<String, dynamic>> points) async {
    if (points.isEmpty) return;
    final batch = _firestore.batch();
    final col = _firestore.collection('users').doc(uid).collection('telemetry');
    for (var p in points) {
      final ref = col.doc();
      batch.set(ref, p);
    }
    await batch.commit();
  }

  Future<void> writeTelemetryPoint(
      String uid, Map<String, dynamic> point) async {
    final col = _firestore.collection('users').doc(uid).collection('telemetry');
    await col.add(point);
  }
}

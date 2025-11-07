import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'device_repository.dart';

/// Durable telemetry buffer using Hive for local storage and periodic batch
/// writes to Firestore. This protects against app restarts and network loss.
class TelemetryBuffer {
  static const _boxName = 'telemetry_buffer';
  Box? _box;
  Timer? _timer;
  final _period = const Duration(seconds: 15);

  // Firestore access is via DeviceRepository when flushing.

  TelemetryBuffer._();
  static TelemetryBuffer? _instance;
  static TelemetryBuffer get instance => _instance ??= TelemetryBuffer._();

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _timer = Timer.periodic(_period, (_) => _flush());
  }

  Future<void> push(Map<String, dynamic> point) async {
    if (_box == null) await initialize();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _box!.put(id, point);
    // flush immediately if buffer grows large
    if (_box!.length >= 100) await _flush();
  }

  Future<void> _flush() async {
    if (_box == null || _box!.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // wait for auth

    final pending = <Map<String, dynamic>>[];
    final keys = _box!.keys.cast<String>().toList();
    for (var k in keys) {
      final v = _box!.get(k);
      if (v is Map) pending.add(Map<String, dynamic>.from(v));
    }

    if (pending.isEmpty) return;

    try {
      // use DeviceRepository batch writer
      await DeviceRepository.instance.writeTelemetryBatch(uid, pending);
      // clear local buffer
      await _box!.clear();
    } catch (e) {
      // leave entries for retry
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _box?.close();
  }
}

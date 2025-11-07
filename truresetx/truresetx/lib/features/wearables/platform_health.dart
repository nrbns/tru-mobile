import 'package:flutter/services.dart';

/// Platform channel stubs for HealthKit (iOS) and Google Fit (Android).
/// Native implementations should implement the methods below and return
/// JSON-serializable maps.
class PlatformHealth {
  static const _channel = MethodChannel('truresetx.health');

  /// Request permissions for health data categories. On iOS this should
  /// request HealthKit permissions; on Android request Google Fit / permissions.
  static Future<bool> requestPermissions(List<String> categories) async {
    try {
      final res = await _channel
          .invokeMethod('requestPermissions', {'categories': categories});
      return res == true;
    } catch (e) {
      return false;
    }
  }

  /// Read recent samples for a given category like 'heart_rate' or 'steps'.
  /// Returns a list of maps: [{ 'value': 78, 'timestamp': '...' }, ...]
  static Future<List<Map<String, dynamic>>> readSamples(String category,
      {int limit = 100}) async {
    try {
      final res = await _channel
          .invokeMethod('readSamples', {'category': category, 'limit': limit});
      if (res is List) {
        return List<Map<String, dynamic>>.from(
            res.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (_) {}
    return [];
  }
}

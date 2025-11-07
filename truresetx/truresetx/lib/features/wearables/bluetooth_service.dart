import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Lightweight BLE helper for the main app. This mirrors the sample code
/// in `wearable_sample` but is placed inside the main `truresetx` app.
class WearableBleService {
  final _ble = FlutterReactiveBle();
  final _discovered = <String, SimpleDevice>{};
  final _devicesController = StreamController<List<SimpleDevice>>.broadcast();
  Stream<List<SimpleDevice>> get discoveredDevicesStream =>
      _devicesController.stream;

  StreamSubscription? _scanSub;

  void startScan() {
    _discovered.clear();
    _scanSub = _ble.scanForDevices(withServices: []).listen((d) {
      _discovered[d.id] = SimpleDevice(d.id, d.name);
      _devicesController.add(_discovered.values.toList());
    }, onError: (_) {});

    Future.delayed(const Duration(seconds: 10), () => stopScan());
  }

  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
  }

  Future<StreamSubscription<List<int>>> connectAndSubscribeHeartRate(
    String deviceId,
    Future<void> Function(int hr) onHeartRate,
  ) async {
    final connection = _ble.connectToDevice(
        id: deviceId, connectionTimeout: const Duration(seconds: 10));
    connection.listen((_) {}, onError: (_) {});

    final hrService = Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb');
    final hrMeasurement = Uuid.parse('00002a37-0000-1000-8000-00805f9b34fb');

    final qual = QualifiedCharacteristic(
        serviceId: hrService,
        characteristicId: hrMeasurement,
        deviceId: deviceId);

    final sub = _ble.subscribeToCharacteristic(qual).listen((data) async {
      try {
        if (data.isEmpty) {
          return;
        }
        final flags = data[0];
        final hr8bit = (flags & 0x01) == 0;
        int hr;
        if (hr8bit) {
          if (data.length >= 2) {
            hr = data[1];
          } else {
            return;
          }
        } else {
          if (data.length >= 3) {
            hr = (data[2] << 8) | data[1];
          } else {
            return;
          }
        }
        await onHeartRate(hr);
      } catch (_) {}
    }, onError: (_) {});

    return sub;
  }

  void dispose() {
    _scanSub?.cancel();
    _devicesController.close();
  }
}

class SimpleDevice {
  final String id;
  final String name;
  SimpleDevice(this.id, this.name);
}

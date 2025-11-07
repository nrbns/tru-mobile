import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bluetooth_service.dart';
import 'device_repository.dart';
import 'telemetry_buffer.dart';

final wearableBleProvider = Provider((ref) => WearableBleService());

class WearablesScreen extends ConsumerStatefulWidget {
  const WearablesScreen({super.key});

  @override
  ConsumerState<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends ConsumerState<WearablesScreen> {
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = ref.watch(wearableBleProvider);
    final repo = DeviceRepository.instance;
    final buffer = TelemetryBuffer.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Wearables')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () => ble.startScan(),
              child: const Text('Scan for devices'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SimpleDevice>>(
              stream: ble.discoveredDevicesStream,
              builder: (context, snap) {
                final devices = snap.data ?? [];
                if (devices.isEmpty) {
                  return const Center(child: Text('No devices'));
                }
                return ListView.separated(
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, idx) {
                    final d = devices[idx];
                    return ListTile(
                      title: Text(d.name.isEmpty ? d.id : d.name),
                      subtitle: Text(d.id),
                      trailing: ElevatedButton(
                        onPressed: uid == null
                            ? null
                            : () async {
                                // register device
                                await repo.registerDevice(uid, d.id, {
                                  'vendor': 'ble',
                                  'name': d.name,
                                });

                                // subscribe to HR and push telemetry to local buffer which will batch to Firestore
                                _sub = await ble.connectAndSubscribeHeartRate(
                                    d.id, (hrValue) async {
                                  final point = {
                                    'type': 'heart_rate',
                                    'deviceId': d.id,
                                    'value': hrValue,
                                    'unit': 'bpm',
                                    'timestamp':
                                        DateTime.now().toIso8601String(),
                                    'quality': 'good',
                                  };
                                  await buffer.push(point);
                                });

                                if (!mounted) return;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Paired and subscribed')));
                                });
                              },
                        child: const Text('Pair & Subscribe'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

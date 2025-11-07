import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/device_integration_service.dart';
// removed unused provider import
import '../../data/models/device_data.dart';
import '../../data/models/health_metrics.dart';

class DeviceIntegrationWidget extends ConsumerWidget {
  const DeviceIntegrationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevices = ref.watch(connectedDevicesProvider);
    final deviceData = ref.watch(deviceDataProvider);
    final healthMetrics = ref.watch(healthMetricsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Integration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sync with your fitness devices',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Connected Devices
            _buildConnectedDevices(connectedDevices),
            const SizedBox(height: 16),

            // Live Health Data (fixed size to avoid layout overflow)
            SizedBox(
              height: 140,
              child: healthMetrics.when(
                data: (metrics) => _buildHealthData(metrics),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Error loading live data: $error')),
              ),
            ),

            const SizedBox(height: 12),

            // Device Data Stream
            deviceData.when(
              data: (data) => _buildDeviceData(data),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevices(List<DeviceConnection> devices) {
    if (devices.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.device_unknown, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No devices connected',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Connect a fitness device to sync your health data',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connected Devices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...devices.map((device) => _buildDeviceItem(device)),
      ],
    );
  }

  Widget _buildDeviceItem(DeviceConnection device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: device.isConnected
            ? Colors.green.withAlpha((0.06 * 255).round())
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: device.isConnected ? Colors.green.shade200 : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getDeviceIcon(device.deviceType),
            color: device.isConnected ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDeviceName(device.deviceType),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  device.isConnected
                      ? 'Connected • ${_formatLastSync(device.lastSync)}'
                      : 'Disconnected',
                  style: TextStyle(
                    color: device.isConnected ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: device.isConnected ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthData(HealthMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text(
                'Live Health Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHealthMetric(
                  'Heart Rate',
                  '${metrics.heartRate ?? '--'} BPM',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildHealthMetric(
                  'Steps',
                  '${metrics.steps ?? '--'}',
                  Icons.directions_walk,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildHealthMetric(
                  'Calories',
                  '${metrics.calories ?? '--'}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildHealthMetric(
                  'Distance',
                  metrics.getFormattedDistance(),
                  Icons.straighten,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceData(DeviceData data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wifi, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Device Data Stream',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              'Device: ${_getDeviceName(_getDeviceTypeFromString(data.deviceType))}'),
          Text('Last Update: ${_formatTimestamp(data.timestamp)}'),
          if (data.heartRate != null) Text('Heart Rate: ${data.heartRate} BPM'),
          if (data.steps != null) Text('Steps: ${data.steps}'),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType deviceType) {
    IconData icon = Icons.device_unknown;
    switch (deviceType) {
      case DeviceType.appleWatch:
        icon = Icons.watch;
        break;
      case DeviceType.fitbit:
        icon = Icons.fitness_center;
        break;
      case DeviceType.garmin:
        icon = Icons.sports;
        break;
      case DeviceType.samsungGalaxyWatch:
        icon = Icons.watch;
        break;
      case DeviceType.noise:
        icon = Icons.watch;
        break;
      case DeviceType.boat:
        icon = Icons.watch;
        break;
      case DeviceType.xiaomi:
        icon = Icons.fitness_center;
        break;
      case DeviceType.huawei:
        icon = Icons.fitness_center;
        break;
      case DeviceType.polar:
        icon = Icons.sports;
        break;
      case DeviceType.suunto:
        icon = Icons.sports;
        break;
    }
    return icon;
  }

  String _getDeviceName(DeviceType deviceType) {
    String name = 'Unknown Device';
    switch (deviceType) {
      case DeviceType.appleWatch:
        name = 'Apple Watch';
        break;
      case DeviceType.fitbit:
        name = 'Fitbit';
        break;
      case DeviceType.garmin:
        name = 'Garmin';
        break;
      case DeviceType.samsungGalaxyWatch:
        name = 'Samsung Galaxy Watch';
        break;
      case DeviceType.noise:
        name = 'Noise Smartwatch';
        break;
      case DeviceType.boat:
        name = 'Boat Smartwatch';
        break;
      case DeviceType.xiaomi:
        name = 'Xiaomi Mi Band';
        break;
      case DeviceType.huawei:
        name = 'Huawei Band';
        break;
      case DeviceType.polar:
        name = 'Polar';
        break;
      case DeviceType.suunto:
        name = 'Suunto';
        break;
    }
    return name;
  }

  DeviceType _getDeviceTypeFromString(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'apple_watch':
        return DeviceType.appleWatch;
      case 'fitbit':
        return DeviceType.fitbit;
      case 'garmin':
        return DeviceType.garmin;
      case 'samsung_galaxy_watch':
        return DeviceType.samsungGalaxyWatch;
      case 'noise':
        return DeviceType.noise;
      case 'boat':
        return DeviceType.boat;
      case 'xiaomi':
        return DeviceType.xiaomi;
      case 'huawei':
        return DeviceType.huawei;
      case 'polar':
        return DeviceType.polar;
      case 'suunto':
        return DeviceType.suunto;
      default:
        return DeviceType.fitbit; // Default fallback
    }
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// ignore_for_file: unreachable_switch_default, dead_code, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/services/enhanced_notification_service.dart';
import '../../core/services/device_integration_service.dart';
import '../devices/device_management_screen.dart';
import '../../core/services/auth_backend.dart';
// removed unused import

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationService = ref.watch(enhancedNotificationServiceProvider);
    final deviceService = ref.watch(deviceIntegrationServiceProvider);
    final connectedDevices = ref.watch(connectedDevicesProvider);
    final selectedBackend = ref.watch(authBackendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Backend Selection
            _buildSectionHeader('Authentication Backend'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('Backend: '),
                    const SizedBox(width: 12),
                    DropdownButton<AuthBackend>(
                      value: selectedBackend,
                      items: const [
                        DropdownMenuItem(
                            value: AuthBackend.supabase,
                            child: Text('Supabase')),
                        DropdownMenuItem(
                            value: AuthBackend.firebase,
                            child: Text('Firebase')),
                        DropdownMenuItem(
                            value: AuthBackend.clerk, child: Text('Clerk')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(authBackendProvider.notifier).setBackend(v);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildNotificationSettings(notificationService),
            const SizedBox(height: 24),

            // Device Integration Section
            _buildSectionHeader('Device Integration'),
            _buildDeviceSettings(deviceService, connectedDevices),
            const SizedBox(height: 24),

            // Permissions Section
            _buildSectionHeader('Permissions'),
            _buildPermissionsSection(),
            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            _buildAppSettings(),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(EnhancedNotificationService service) {
    final settings = service.getNotificationSettings();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Enable Notifications',
              subtitle: 'Receive notifications from TruResetX',
              value: settings['enabled'] as bool,
              onChanged: (value) {
                service.updateNotificationSettings(enabled: value);
              },
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'Popup Notifications',
              subtitle: 'Show notification popups',
              value: settings['popup'] as bool,
              onChanged: (value) {
                service.updateNotificationSettings(popup: value);
              },
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'Sound',
              subtitle: 'Play notification sounds',
              value: settings['sound'] as bool,
              onChanged: (value) {
                service.updateNotificationSettings(sound: value);
              },
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: settings['vibration'] as bool,
              onChanged: (value) {
                service.updateNotificationSettings(vibration: value);
              },
            ),
            const Divider(),
            _buildCategorySettings(settings['categories'] as Map<String, bool>),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySettings(Map<String, bool> categories) {
    return ExpansionTile(
      title: const Text('Notification Categories'),
      subtitle: const Text('Customize notification types'),
      children: categories.entries.map((entry) {
        return _buildSwitchTile(
          title: _getCategoryTitle(entry.key),
          subtitle: _getCategoryDescription(entry.key),
          value: entry.value,
          onChanged: (value) {
            final newCategories = Map<String, bool>.from(categories);
            newCategories[entry.key] = value;
            ref
                .read(enhancedNotificationServiceProvider)
                .updateNotificationSettings(categorySettings: newCategories);
          },
        );
      }).toList(),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'workout':
        return 'Workout Reminders';
      case 'nutrition':
        return 'Nutrition Reminders';
      case 'mood':
        return 'Mood Reminders';
      case 'meditation':
        return 'Meditation Reminders';
      case 'reminder':
        return 'General Reminders';
      case 'achievement':
        return 'Achievements';
      case 'live_update':
        return 'Live Updates';
      default:
        return category;
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'workout':
        return 'Workout reminders and achievements';
      case 'nutrition':
        return 'Meal logging and nutrition goals';
      case 'mood':
        return 'Mood check-ins and wellness insights';
      case 'meditation':
        return 'Meditation sessions and mindfulness';
      case 'reminder':
        return 'General app reminders';
      case 'achievement':
        return 'Wellness achievements and milestones';
      case 'live_update':
        return 'Real-time data updates';
      default:
        return 'Notification category';
    }
  }

  Widget _buildDeviceSettings(DeviceIntegrationService service,
      List<DeviceConnection> connectedDevices) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDeviceList(service, connectedDevices),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDeviceDialog(service),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Device'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openDeviceManagement(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Manage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(
      DeviceIntegrationService service, List<DeviceConnection> devices) {
    if (devices.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.device_unknown),
        title: Text('No devices connected'),
        subtitle: Text('Add a fitness device to sync your health data'),
      );
    }

    return Column(
      children: devices.map((device) {
        return ListTile(
          leading: Icon(_getDeviceIcon(device.deviceType)),
          title: Text(_getDeviceName(device.deviceType)),
          subtitle: Text(
            device.isConnected
                ? 'Connected • Last sync: ${_formatLastSync(device.lastSync)}'
                : 'Disconnected',
          ),
          trailing: Switch(
            value: device.isConnected,
            onChanged: (value) {
              if (value) {
                service.connectDevice(_getDeviceId(device.deviceType));
              } else {
                service.disconnectDevice(_getDeviceId(device.deviceType));
              }
            },
          ),
          onTap: () => _showDeviceDetails(device),
        );
      }).toList(),
    );
  }

  Widget _buildPermissionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPermissionTile(
              title: 'Notifications',
              subtitle: 'Allow TruResetX to send notifications',
              permission: Permission.notification,
            ),
            const Divider(),
            _buildPermissionTile(
              title: 'Bluetooth',
              subtitle: 'Connect to fitness devices',
              permission: Permission.bluetooth,
            ),
            const Divider(),
            _buildPermissionTile(
              title: 'Activity Recognition',
              subtitle: 'Track your physical activity',
              permission: Permission.activityRecognition,
            ),
            const Divider(),
            _buildPermissionTile(
              title: 'Sensors',
              subtitle: 'Access device sensors for health data',
              permission: Permission.sensors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required Permission permission,
  }) {
    return FutureBuilder<PermissionStatus>(
      future: permission.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? PermissionStatus.denied;
        final isGranted = status.isGranted;

        return ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGranted ? Icons.check_circle : Icons.cancel,
                color: isGranted ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  if (isGranted) {
                    await permission.request();
                  } else {
                    await openAppSettings();
                  }
                },
                child: Text(isGranted ? 'Granted' : 'Grant'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              value: false,
              onChanged: (value) {
                // Implement dark mode toggle
              },
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'Auto Sync',
              subtitle: 'Automatically sync data with devices',
              value: true,
              onChanged: (value) {
                // Implement auto sync toggle
              },
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'Live Tracking',
              subtitle: 'Enable real-time data tracking',
              value: true,
              onChanged: (value) {
                // Implement live tracking toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy Policy'),
              subtitle: Text('View our privacy policy'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Terms of Service'),
              subtitle: Text('View terms and conditions'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              subtitle: Text('Get help and contact support'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  IconData _getDeviceIcon(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.appleWatch:
        return Icons.watch;
      case DeviceType.fitbit:
        return Icons.fitness_center;
      case DeviceType.garmin:
        return Icons.sports;
      case DeviceType.samsungGalaxyWatch:
        return Icons.watch;
      case DeviceType.noise:
        return Icons.watch;
      case DeviceType.boat:
        return Icons.watch;
      case DeviceType.xiaomi:
        return Icons.fitness_center;
      case DeviceType.huawei:
        return Icons.fitness_center;
      case DeviceType.polar:
        return Icons.sports;
      case DeviceType.suunto:
        return Icons.sports;
      default:
        return Icons.device_unknown;
    }
  }

  String _getDeviceName(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.appleWatch:
        return 'Apple Watch';
      case DeviceType.fitbit:
        return 'Fitbit';
      case DeviceType.garmin:
        return 'Garmin';
      case DeviceType.samsungGalaxyWatch:
        return 'Samsung Galaxy Watch';
      case DeviceType.noise:
        return 'Noise Smartwatch';
      case DeviceType.boat:
        return 'Boat Smartwatch';
      case DeviceType.xiaomi:
        return 'Xiaomi Mi Band';
      case DeviceType.huawei:
        return 'Huawei Band';
      case DeviceType.polar:
        return 'Polar';
      case DeviceType.suunto:
        return 'Suunto';
      default:
        return 'Unknown Device';
    }
  }

  String _getDeviceId(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.appleWatch:
        return 'apple_watch';
      case DeviceType.fitbit:
        return 'fitbit';
      case DeviceType.garmin:
        return 'garmin';
      case DeviceType.samsungGalaxyWatch:
        return 'samsung_galaxy_watch';
      case DeviceType.noise:
        return 'noise';
      case DeviceType.boat:
        return 'boat';
      case DeviceType.xiaomi:
        return 'xiaomi';
      case DeviceType.huawei:
        return 'huawei';
      case DeviceType.polar:
        return 'polar';
      case DeviceType.suunto:
        return 'suunto';
      default:
        return 'unknown';
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

  void _showAddDeviceDialog(DeviceIntegrationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Device'),
        content: const Text('Select a device to connect:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement device connection
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _openDeviceManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeviceManagementScreen(),
      ),
    );
  }

  void _showDeviceDetails(DeviceConnection device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getDeviceName(device.deviceType)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Status: ${device.isConnected ? 'Connected' : 'Disconnected'}'),
            if (device.lastSync != null)
              Text('Last Sync: ${_formatLastSync(device.lastSync)}'),
            const SizedBox(height: 16),
            const Text('Capabilities:'),
            ...device.capabilities.map(
                (capability) => Text('• ${_getCapabilityName(capability)}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getCapabilityName(DeviceCapability capability) {
    switch (capability) {
      case DeviceCapability.heartRate:
        return 'Heart Rate';
      case DeviceCapability.steps:
        return 'Step Counting';
      case DeviceCapability.sleep:
        return 'Sleep Tracking';
      case DeviceCapability.calories:
        return 'Calorie Tracking';
      case DeviceCapability.distance:
        return 'Distance Tracking';
      case DeviceCapability.activeMinutes:
        return 'Active Minutes';
      case DeviceCapability.gps:
        return 'GPS Tracking';
      case DeviceCapability.workout:
        return 'Workout Tracking';
      case DeviceCapability.ecg:
        return 'ECG Monitoring';
      case DeviceCapability.bloodOxygen:
        return 'Blood Oxygen';
      case DeviceCapability.bloodPressure:
        return 'Blood Pressure';
    }
  }
}

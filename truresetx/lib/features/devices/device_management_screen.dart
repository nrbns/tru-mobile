import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/device_integration_service.dart';
import '../../data/models/device_data.dart';

class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  ConsumerState<DeviceManagementScreen> createState() =>
      _DeviceManagementScreenState();
}

class _DeviceManagementScreenState
    extends ConsumerState<DeviceManagementScreen> {
  bool _isScanning = false;
  List<DeviceConnection> _availableDevices = [];
  // _connectedDevices was unused; rely on provider for connected devices

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
  }

  @override
  Widget build(BuildContext context) {
    final connectedDevices = ref.watch(connectedDevicesProvider);
    final deviceData = ref.watch(deviceDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _startDeviceScan,
            icon: Icon(_isScanning ? Icons.stop : Icons.radar),
            tooltip: _isScanning ? 'Stop Scanning' : 'Scan for Devices',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Connected Devices
            _buildConnectedDevicesSection(connectedDevices),
            const SizedBox(height: 24),

            // Available Devices (when scanning)
            if (_isScanning) ...[
              _buildAvailableDevicesSection(),
              const SizedBox(height: 24),
            ],

            // Device Data Stream
            _buildDeviceDataSection(deviceData),
            const SizedBox(height: 24),

            // Supported Devices
            _buildSupportedDevicesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withAlpha((0.1 * 255).round()),
            Colors.purple.withAlpha((0.1 * 255).round())
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.devices,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Integration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connect your fitness devices to sync health data',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.radar,
            title: 'Scan Devices',
            subtitle: 'Find nearby devices',
            color: Colors.blue,
            onTap: _startDeviceScan,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_circle_outline,
            title: 'Add Manually',
            subtitle: 'Add device by type',
            color: Colors.green,
            onTap: _showAddDeviceDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevicesSection(
      List<DeviceConnection> connectedDevices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Connected Devices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${connectedDevices.length} connected',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (connectedDevices.isEmpty)
          _buildEmptyState()
        else
          ...connectedDevices
              .map((device) => _buildConnectedDeviceCard(device)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.device_unknown,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No devices connected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect a fitness device to start syncing your health data',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startDeviceScan,
            icon: const Icon(Icons.radar),
            label: const Text('Scan for Devices'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDeviceCard(DeviceConnection device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: device.isConnected
            ? Colors.green.withAlpha((0.1 * 255).round())
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: device.isConnected ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isConnected ? Colors.green : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDeviceIcon(device.deviceType),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDeviceName(device.deviceType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.isConnected
                      ? 'Connected • Last sync: ${_formatLastSync(device.lastSync)}'
                      : 'Disconnected',
                  style: TextStyle(
                    color: device.isConnected ? Colors.green : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleDeviceAction(value, device),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 20),
                    SizedBox(width: 8),
                    Text('Sync Now'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'disconnect',
                child: Row(
                  children: [
                    Icon(Icons.link_off, size: 20),
                    SizedBox(width: 8),
                    Text('Disconnect'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Devices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isScanning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_availableDevices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.radar,
                  size: 48,
                  color: Colors.blue,
                ),
                SizedBox(height: 12),
                Text(
                  'Scanning for devices...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Make sure your device is nearby and in pairing mode',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._availableDevices
              .map((device) => _buildAvailableDeviceCard(device)),
      ],
    );
  }

  Widget _buildAvailableDeviceCard(DeviceConnection device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDeviceIcon(device.deviceType),
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDeviceName(device.deviceType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to connect',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _connectDevice(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceDataSection(AsyncValue<DeviceData?> deviceData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Data Stream',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        deviceData.when(
          data: (data) =>
              data != null ? _buildLiveDataCard(data) : _buildNoDataCard(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorCard(error.toString()),
        ),
      ],
    );
  }

  Widget _buildLiveDataCard(DeviceData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withAlpha((0.1 * 255).round()),
            Colors.blue.withAlpha((0.1 * 255).round())
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Live Data Stream',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDataMetric(
                  'Device',
                  _getDeviceName(_getDeviceTypeFromString(data.deviceType)),
                  Icons.devices,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildDataMetric(
                  'Last Update',
                  _formatTimestamp(data.timestamp),
                  Icons.access_time,
                  Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (data.heartRate != null)
                Expanded(
                  child: _buildDataMetric(
                    'Heart Rate',
                    '${data.heartRate} BPM',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              if (data.steps != null)
                Expanded(
                  child: _buildDataMetric(
                    'Steps',
                    '${data.steps}',
                    Icons.directions_walk,
                    Colors.blue,
                  ),
                ),
            ],
          ),
          if (data.calories != null || data.distance != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (data.calories != null)
                  Expanded(
                    child: _buildDataMetric(
                      'Calories',
                      '${data.calories}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                if (data.distance != null)
                  Expanded(
                    child: _buildDataMetric(
                      'Distance',
                      '${data.distance!.toStringAsFixed(1)} km',
                      Icons.straighten,
                      Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataMetric(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
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

  Widget _buildNoDataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No live data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Connect a device to see live health data',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Error loading data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supported Devices',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildSupportedDeviceCard('Apple Watch', Icons.watch, Colors.blue),
            _buildSupportedDeviceCard(
                'Fitbit', Icons.fitness_center, Colors.green),
            _buildSupportedDeviceCard('Garmin', Icons.sports, Colors.orange),
            _buildSupportedDeviceCard(
                'Samsung Galaxy', Icons.watch, Colors.purple),
            _buildSupportedDeviceCard('Noise', Icons.watch, Colors.red),
            _buildSupportedDeviceCard('Boat', Icons.watch, Colors.teal),
            _buildSupportedDeviceCard(
                'Xiaomi Mi Band', Icons.fitness_center, Colors.orange),
            _buildSupportedDeviceCard(
                'Huawei Band', Icons.fitness_center, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportedDeviceCard(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadConnectedDevices() {
    // This would load from the device service; providers supply the data
    // Trigger a rebuild so provider values are picked up in build()
    setState(() {});
  }

  void _startDeviceScan() {
    setState(() {
      _isScanning = true;
      _availableDevices = [];
    });

    // Simulate device scanning
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _availableDevices = _generateMockDevices();
        });
      }
    });
  }

  List<DeviceConnection> _generateMockDevices() {
    return [
      DeviceConnection(
        deviceId: 'device_1',
        deviceType: DeviceType.appleWatch,
        deviceName: 'Apple Watch Series 9',
        isConnected: false,
        lastSync: null,
      ),
      DeviceConnection(
        deviceId: 'device_2',
        deviceType: DeviceType.fitbit,
        deviceName: 'Fitbit Charge 5',
        isConnected: false,
        lastSync: null,
      ),
      DeviceConnection(
        deviceId: 'device_3',
        deviceType: DeviceType.garmin,
        deviceName: 'Garmin Venu 3',
        isConnected: false,
        lastSync: null,
      ),
    ];
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DeviceType.values
              .map((type) => ListTile(
                    leading: Icon(_getDeviceIcon(type)),
                    title: Text(_getDeviceName(type)),
                    onTap: () {
                      Navigator.pop(context);
                      _addDeviceManually(type);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addDeviceManually(DeviceType deviceType) {
    final device = DeviceConnection(
      deviceId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      deviceType: deviceType,
      deviceName: _getDeviceName(deviceType),
      isConnected: false,
      lastSync: null,
    );

    // Add to connected devices
    ref.read(connectedDevicesProvider.notifier).addDevice(device);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getDeviceName(deviceType)} added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _connectDevice(DeviceConnection device) {
    // Simulate connection process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Connecting to device...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Update device connection status
      final updatedDevice = DeviceConnection(
        deviceId: device.deviceId,
        deviceType: device.deviceType,
        deviceName: device.deviceName,
        isConnected: true,
        lastSync: DateTime.now(),
      );

      ref.read(connectedDevicesProvider.notifier).updateDevice(updatedDevice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.deviceName}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _handleDeviceAction(String action, DeviceConnection device) {
    switch (action) {
      case 'sync':
        _syncDevice(device);
        break;
      case 'settings':
        _showDeviceSettings(device);
        break;
      case 'disconnect':
        _disconnectDevice(device);
        break;
    }
  }

  void _syncDevice(DeviceConnection device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing ${device.deviceName}...'),
        backgroundColor: Colors.blue,
      ),
    );

    // Simulate sync process
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final updatedDevice = DeviceConnection(
        deviceId: device.deviceId,
        deviceType: device.deviceType,
        deviceName: device.deviceName,
        isConnected: device.isConnected,
        lastSync: DateTime.now(),
      );

      ref.read(connectedDevicesProvider.notifier).updateDevice(updatedDevice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${device.deviceName} synced successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showDeviceSettings(DeviceConnection device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${device.deviceName} Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Automatically sync data'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive device notifications'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Heart Rate Monitoring'),
              subtitle: const Text('Track heart rate continuously'),
              value: true,
              onChanged: (value) {},
            ),
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

  void _disconnectDevice(DeviceConnection device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Device'),
        content:
            Text('Are you sure you want to disconnect ${device.deviceName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(connectedDevicesProvider.notifier)
                  .removeDevice(device.deviceId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${device.deviceName} disconnected'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
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
    }
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
        return DeviceType.fitbit;
    }
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';
    return _formatTimestamp(lastSync);
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

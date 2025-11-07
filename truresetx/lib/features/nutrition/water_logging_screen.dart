import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/water_log_models.dart';
import '../../core/services/realtime_service.dart';

/// Water Logging Screen for tracking daily water intake
class WaterLoggingScreen extends ConsumerStatefulWidget {
  const WaterLoggingScreen({super.key});

  @override
  ConsumerState<WaterLoggingScreen> createState() => _WaterLoggingScreenState();
}

class _WaterLoggingScreenState extends ConsumerState<WaterLoggingScreen>
    with TickerProviderStateMixin {
  late AnimationController _waterLevelController;
  late AnimationController _glowController;
  late Animation<double> _waterLevelAnimation;
  late Animation<double> _glowAnimation;

  double _currentIntake = 0.0;
  double _dailyGoal = 2000.0; // ml
  List<WaterLog> _waterLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _waterLevelController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waterLevelAnimation = Tween<double>(
      begin: 0.0,
      end: _currentIntake / _dailyGoal,
    ).animate(CurvedAnimation(
      parent: _waterLevelController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _loadWaterLogs();

    // Listen for realtime events and handle water-related updates.
    // Uses the app-wide RealtimeService's stream provider which emits
    // maps like { type: 'food_log'|'nutrition_update'|'live_metrics', data: {...} }
    // We listen via Riverpod's ref.listen so updates are automatically
    // managed with the widget lifecycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Safe to use ref.listen here after the first frame
      ref.listen<AsyncValue<Map<String, dynamic>>>(
        realtimeDataProvider,
        (previous, next) {
          next.whenData((message) {
            try {
              final payload = (message['data'] ?? message['payload'])
                  as Map<String, dynamic>?;
              if (payload == null) return;

              // Try to detect water log-like payloads
              double? amount;
              if (payload['amount'] is num) {
                amount = (payload['amount'] as num).toDouble();
              } else if (payload['servingQty'] is num) {
                amount = (payload['servingQty'] as num).toDouble();
              }

              final name = payload['name']?.toString();
              final category =
                  (payload['category']?.toString() ?? '').toLowerCase();
              final isWaterByName =
                  (name ?? '').toLowerCase().contains('water');
              final isWaterByCategory =
                  category.contains('beverage') || category.contains('water');
              final isWaterFlag = payload['is_water'] == true;

              final likelyWater =
                  isWaterByName || isWaterByCategory || isWaterFlag;

              if (amount != null && likelyWater) {
                final log = WaterLog(
                  id: payload['id']?.toString() ??
                      'ws_${DateTime.now().millisecondsSinceEpoch}',
                  userId: payload['userId']?.toString() ?? 'unknown',
                  amount: amount,
                  timestamp: DateTime.tryParse(
                          payload['detectedAt']?.toString() ?? '') ??
                      DateTime.now(),
                  notes: payload['notes']?.toString(),
                );

                // Update UI state
                setState(() {
                  _waterLogs.insert(0, log);
                  _currentIntake += amount!;
                });

                _updateWaterLevel();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New water logged: ${amount.toInt()} ml'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            } catch (e) {
              // non-fatal; ignore parse errors
            }
          });
        },
      );
    });
  }

  @override
  void dispose() {
    _waterLevelController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadWaterLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load today's water logs
      final today = DateTime.now();
      final logs = await _getTodayWaterLogs(today);

      setState(() {
        _waterLogs = logs;
        _currentIntake = logs.fold(0.0, (sum, log) => sum + log.amount);
      });

      _updateWaterLevel();
    } catch (e) {
      print('Error loading water logs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<WaterLog>> _getTodayWaterLogs(DateTime date) async {
    // Simulate loading water logs
    return [
      WaterLog(
        id: '1',
        userId: 'current_user',
        amount: 250.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        notes: 'Morning water',
      ),
      WaterLog(
        id: '2',
        userId: 'current_user',
        amount: 300.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        notes: 'After workout',
      ),
    ];
  }

  void _updateWaterLevel() {
    _waterLevelAnimation = Tween<double>(
      begin: 0.0,
      end: (_currentIntake / _dailyGoal).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _waterLevelController,
      curve: Curves.easeInOut,
    ));

    _waterLevelController.forward();

    if (_currentIntake >= _dailyGoal) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Water Level Visualization
                  _buildWaterLevelVisualization(),
                  const SizedBox(height: 32),

                  // Progress Stats
                  _buildProgressStats(),
                  const SizedBox(height: 32),

                  // Quick Add Buttons
                  _buildQuickAddButtons(),
                  const SizedBox(height: 32),

                  // Recent Logs
                  _buildRecentLogs(),
                  const SizedBox(height: 32),

                  // Custom Amount Input
                  _buildCustomAmountInput(),
                ],
              ),
            ),
    );
  }

  Widget _buildWaterLevelVisualization() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withAlpha((0.3 * 255).round())),
      ),
      child: Stack(
        children: [
          // Water bottle outline
          Center(
            child: Container(
              width: 120,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Water level
          Center(
            child: AnimatedBuilder(
              animation: _waterLevelAnimation,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 250 * _waterLevelAnimation.value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.withAlpha((0.8 * 255).round()),
                        Colors.blue.withAlpha((0.6 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                );
              },
            ),
          ),

          // Glow effect when goal is reached
          if (_currentIntake >= _dailyGoal)
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120 + (_glowAnimation.value * 20),
                    height: 250 + (_glowAnimation.value * 20),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(
                          (_glowAnimation.value * 0.3 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

          // Progress text
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '${_currentIntake.toInt()} / ${_dailyGoal.toInt()} ml',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${((_currentIntake / _dailyGoal) * 100).toInt()}% of daily goal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats() {
    final progress = (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
    final remaining = (_dailyGoal - _currentIntake).clamp(0.0, _dailyGoal);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Progress',
            '${(progress * 100).toInt()}%',
            Icons.trending_up,
            Colors.blue,
            progress,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Remaining',
            '${remaining.toInt()} ml',
            Icons.water_drop,
            Colors.orange,
            remaining / _dailyGoal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Logs Today',
            '${_waterLogs.length}',
            Icons.list,
            Colors.green,
            1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    final quickAmounts = [100.0, 250.0, 500.0, 750.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: quickAmounts.map((amount) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () => _addWater(amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('${amount.toInt()}ml'),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentLogs() {
    if (_waterLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.water_drop, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No water logged today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Start tracking your water intake',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Logs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._waterLogs.take(5).map((log) => _buildLogItem(log)),
      ],
    );
  }

  Widget _buildLogItem(WaterLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.water_drop, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.amount.toInt()} ml',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (log.notes != null && log.notes!.isNotEmpty)
                  Text(
                    log.notes!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatTime(log.timestamp),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAmountInput() {
    final customController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: customController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (ml)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: 'ml',
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(customController.text);
                if (amount != null && amount > 0) {
                  _addWater(amount);
                  customController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addWater(double amount) async {
    try {
      final waterLog = WaterLog(
        id: 'water_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        amount: amount,
        timestamp: DateTime.now(),
        notes: null,
      );

      // Add to logs
      setState(() {
        _waterLogs.insert(0, waterLog);
        _currentIntake += amount;
      });

      _updateWaterLevel();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${amount.toInt()}ml of water'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Check if goal is reached
      if (_currentIntake >= _dailyGoal) {
        _showGoalAchievedDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add water: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGoalAchievedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 8),
            Text('Goal Achieved!'),
          ],
        ),
        content: const Text(
          'Congratulations! You\'ve reached your daily water intake goal. Keep up the great work!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Daily Goal'),
              subtitle: Text('${_dailyGoal.toInt()} ml'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editDailyGoal(),
            ),
            ListTile(
              title: const Text('Reset Today'),
              subtitle: const Text('Clear all water logs for today'),
              trailing: const Icon(Icons.refresh),
              onTap: () => _resetToday(),
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

  void _editDailyGoal() {
    final controller =
        TextEditingController(text: _dailyGoal.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily Goal (ml)',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = double.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                setState(() {
                  _dailyGoal = newGoal;
                });
                _updateWaterLevel();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetToday() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Today'),
        content: const Text(
            'Are you sure you want to clear all water logs for today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _waterLogs.clear();
                _currentIntake = 0.0;
              });
              _updateWaterLevel();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
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

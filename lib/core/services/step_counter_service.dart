import 'dart:async';
import 'package:flutter/services.dart';
import 'activity_tracking_service.dart';

/// Step Counter Service - Real-time step tracking with Firebase sync
/// Uses platform channels for native step counting
class StepCounterService {
  static const MethodChannel _channel = MethodChannel('truresetx/step_counter');
  final ActivityTrackingService _activityService = ActivityTrackingService();
  
  StreamController<int>? _stepsController;
  StreamSubscription<int>? _stepsSubscription;
  Timer? _syncTimer;
  
  bool _isListening = false;
  int _lastSyncedSteps = 0;

  /// Start listening to step count updates
  Stream<int> startStepCounting() {
    if (_isListening) {
      return _stepsController?.stream ?? const Stream.empty();
    }

    _stepsController = StreamController<int>.broadcast();
    _isListening = true;

    // Request permissions (platform-specific)
    _requestPermissions();

    // Start periodic updates from native code
    _channel.setMethodCallHandler(_handleMethodCall);

    // Sync every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncSteps();
    });

    // Initial sync
    _syncSteps();

    return _stepsController!.stream;
  }

  /// Stop listening to step count
  Future<void> stopStepCounting() async {
    _isListening = false;
    await _stepsSubscription?.cancel();
    _stepsController?.close();
    _stepsController = null;
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Request step counter permissions
  Future<void> _requestPermissions() async {
    try {
      await _channel.invokeMethod('requestPermissions');
    } catch (e) {
      print('Failed to request permissions: $e');
    }
  }

  /// Handle method calls from native platform
  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onStepsUpdate') {
      final steps = call.arguments as int;
      _stepsController?.add(steps);
      await _syncToFirebase(steps);
    }
  }

  /// Sync steps from native platform
  Future<void> _syncSteps() async {
    try {
      final steps = await _channel.invokeMethod<int>('getCurrentSteps') ?? 0;
      _stepsController?.add(steps);
      await _syncToFirebase(steps);
    } catch (e) {
      print('Failed to sync steps: $e');
    }
  }

  /// Sync steps to Firebase with real-time updates
  Future<void> _syncToFirebase(int steps) async {
    try {
      // Only sync if steps changed significantly (> 100 steps to reduce writes)
      if ((steps - _lastSyncedSteps).abs() < 100 && _lastSyncedSteps > 0) {
        return;
      }

      _lastSyncedSteps = steps;

      // Log activity with real-time update
      await _activityService.logActivity(
        steps: steps,
        source: 'device_sensor',
      );
    } catch (e) {
      print('Failed to sync steps to Firebase: $e');
    }
  }

  /// Get today's step count
  Future<int> getTodaySteps() async {
    try {
      final steps = await _channel.invokeMethod<int>('getCurrentSteps') ?? 0;
      return steps;
    } catch (e) {
      // Fallback to Firebase data
      final activity = await _activityService.getTodayActivity();
      return activity?['steps'] as int? ?? 0;
    }
  }

  /// Manual step entry (when sensor unavailable)
  Future<void> logManualSteps(int steps) async {
    await _activityService.logActivity(
      steps: steps,
      source: 'manual',
    );
  }
}


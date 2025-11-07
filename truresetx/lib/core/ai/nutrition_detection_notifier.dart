import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/nutrition_agent.dart';

/// A simple notifier that holds detected foods awaiting user confirmation.
class DetectionState {
  DetectionState({required this.items});
  final List<RecognizedFood> items;
}

class NutritionDetectionNotifier extends StateNotifier<DetectionState> {
  NutritionDetectionNotifier(this._ref) : super(DetectionState(items: [])) {
    // subscribe to agent detections
    final agent = _ref.read(nutritionAgentProvider);
    _sub = agent.detectionStream.listen((food) {
      addDetected(food);
    });
  }

  final Ref _ref;
  StreamSubscription<RecognizedFood>? _sub;

  void addDetected(RecognizedFood food) {
    state = DetectionState(items: [food, ...state.items]);
  }

  void confirm(int index) {
    // TODO: wire to logging flow for this item
    final newList = List<RecognizedFood>.from(state.items)..removeAt(index);
    state = DetectionState(items: newList);
  }

  void dismiss(int index) {
    final newList = List<RecognizedFood>.from(state.items)..removeAt(index);
    state = DetectionState(items: newList);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final nutritionDetectionProvider =
    StateNotifierProvider<NutritionDetectionNotifier, DetectionState>((ref) {
  return NutritionDetectionNotifier(ref);
});

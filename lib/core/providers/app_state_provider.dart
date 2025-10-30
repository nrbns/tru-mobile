import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState()) {
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      isShowcaseMode: prefs.getBool('trx-showcase-mode') ?? true,
      currentTab: prefs.getString('trx-current-tab') ?? 'home',
      waterIntake: prefs.getInt('trx-water-intake') ?? 0,
      streakDays: prefs.getInt('trx-streak-days') ?? 12,
    );
  }

  void setShowcaseMode(bool value) {
    state = state.copyWith(isShowcaseMode: value);
    _saveState();
  }

  void setCurrentTab(String tab) {
    state = state.copyWith(currentTab: tab);
    _saveState();
  }

  void updateWaterIntake(int amount) {
    state = state.copyWith(waterIntake: amount);
    _saveState();
  }

  void updateEnergyLevel(int level) {
    state = state.copyWith(energyLevel: level);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trx-showcase-mode', state.isShowcaseMode);
    await prefs.setString('trx-current-tab', state.currentTab);
    await prefs.setInt('trx-water-intake', state.waterIntake);
    await prefs.setInt('trx-streak-days', state.streakDays);
  }
}

class AppState {
  final bool isShowcaseMode;
  final String currentTab;
  final int moodScore;
  final int waterIntake;
  final int energyLevel;
  final int streakDays;
  final int achievementCount;

  AppState({
    this.isShowcaseMode = true,
    this.currentTab = 'home',
    this.moodScore = 0,
    this.waterIntake = 0,
    this.energyLevel = 0,
    this.streakDays = 12,
    this.achievementCount = 24,
  });

  AppState copyWith({
    bool? isShowcaseMode,
    String? currentTab,
    int? moodScore,
    int? waterIntake,
    int? energyLevel,
    int? streakDays,
    int? achievementCount,
  }) {
    return AppState(
      isShowcaseMode: isShowcaseMode ?? this.isShowcaseMode,
      currentTab: currentTab ?? this.currentTab,
      moodScore: moodScore ?? this.moodScore,
      waterIntake: waterIntake ?? this.waterIntake,
      energyLevel: energyLevel ?? this.energyLevel,
      streakDays: streakDays ?? this.streakDays,
      achievementCount: achievementCount ?? this.achievementCount,
    );
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});


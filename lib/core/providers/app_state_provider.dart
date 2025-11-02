import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/today_service.dart';
import '../services/gamification_service.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TodayService _todayService = TodayService();
  final GamificationService _gamificationService = GamificationService();
  
  AppStateNotifier() : super(AppState()) {
    _loadSavedState();
  }

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference? get _userStateRef {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('app_state').doc('current');
  }

  Future<void> _loadSavedState() async {
    // Load from Firestore if authenticated, otherwise use SharedPreferences as fallback
    if (_uid != null && _userStateRef != null) {
      try {
        final doc = await _userStateRef!.get();
        final data = doc.exists ? (doc.data() as Map<String, dynamic>? ?? {}) : {};
        
        // Load achievements count from Firestore
        int achievementCount = 0;
        try {
          final stats = await _gamificationService.getAchievementStats();
          achievementCount = stats['total_achievements'] as int? ?? 0;
        } catch (e) {
          // Use cached value if service fails
          achievementCount = data['achievement_count'] as int? ?? 0;
        }

        // Try to sync from today's data for real-time values
        try {
          final today = await _todayService.getToday();
          state = state.copyWith(
            isShowcaseMode: data['showcase_mode'] ?? true,
            currentTab: data['current_tab'] ?? 'home',
            waterIntake: today.waterMl, // Use real-time from Firestore
            streakDays: today.streak, // Use real-time from Firestore
            achievementCount: achievementCount, // Use real-time from Firestore
          );
          return;
        } catch (e) {
          // Fallback to cached values if today service fails
          state = state.copyWith(
            isShowcaseMode: data['showcase_mode'] ?? true,
            currentTab: data['current_tab'] ?? 'home',
            waterIntake: data['water_intake'] ?? 0,
            streakDays: data['streak_days'] ?? 0,
            achievementCount: achievementCount,
          );
          return;
        }
      } catch (e) {
        // Fallback to SharedPreferences on error
      }
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      isShowcaseMode: prefs.getBool('trx-showcase-mode') ?? true,
      currentTab: prefs.getString('trx-current-tab') ?? 'home',
      waterIntake: prefs.getInt('trx-water-intake') ?? 0,
      streakDays: prefs.getInt('trx-streak-days') ?? 0,
      achievementCount: 0,
    );

    // Try to sync from today's data even in fallback mode
    try {
      final today = await _todayService.getToday();
      final stats = await _gamificationService.getAchievementStats();
      state = state.copyWith(
        waterIntake: today.waterMl,
        streakDays: today.streak,
        achievementCount: stats['total_achievements'] as int? ?? 0,
      );
    } catch (e) {
      // Ignore if services fail
    }
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
    // Also update in Firestore via TodayService
    _todayService.updateWaterIntake(amount);
  }

  void updateEnergyLevel(int level) {
    state = state.copyWith(energyLevel: level);
    _saveState();
  }

  void updateStreakDays(int days) {
    state = state.copyWith(streakDays: days);
    _saveState();
  }

  Future<void> refreshAchievementCount() async {
    try {
      final stats = await _gamificationService.getAchievementStats();
      final count = stats['total_achievements'] as int? ?? 0;
      state = state.copyWith(achievementCount: count);
      _saveState();
    } catch (e) {
      // Ignore errors
    }
  }

  void updateAchievementCount(int count) {
    state = state.copyWith(achievementCount: count);
    _saveState();
  }

  Future<void> _saveState() async {
    // Save to Firestore if authenticated
    if (_uid != null && _userStateRef != null) {
      try {
        await _userStateRef!.set({
          'showcase_mode': state.isShowcaseMode,
          'current_tab': state.currentTab,
          'water_intake': state.waterIntake,
          'streak_days': state.streakDays,
          'achievement_count': state.achievementCount,
          'energy_level': state.energyLevel,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        // Fallback to SharedPreferences on error
      }
    }

    // Also save to SharedPreferences as fallback
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

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

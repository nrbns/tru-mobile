import 'package:flutter/material.dart';

/// TruResetX Aura Theme Colors
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF3B8AFF);
  static const Color secondary = Color(0xFF7F00FF);

  // Background Colors
  static const Color background = Color(0xFF0C0F18);
  static const Color surface = Color(0xFF121624);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC9D1D9);
  static const Color textMuted = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF5350);
  static const Color cyan = Color(0xFF06B6D4);

  // Border Colors
  static const Color border = Color(0xFF1F2937);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, cyan],
  );

  // Aura Glow Colors (avoid deprecated withOpacity; compute alpha)
  static Color primaryGlow = primary.withAlpha((0.35 * 255).round());
  static Color secondaryGlow = secondary.withAlpha((0.3 * 255).round());

  // Variant Colors for Cards
  static const Color moodColor = secondary;
  static const Color nutritionColor = success;
  static const Color workoutColor =
      Color(0xFFFF6B6B); // Red-orange for workouts
  static const Color spiritualColor = warning;
  static const Color aiColor = primary;
}

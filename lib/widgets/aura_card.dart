import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AuraCardVariant {
  default_,
  ai,
  mood,
  nutrition,
  spiritual,
}

class AuraCard extends StatelessWidget {
  final Widget child;
  final AuraCardVariant variant;
  final bool glow;
  final EdgeInsets? padding;

  const AuraCard({
    super.key,
    required this.child,
    this.variant = AuraCardVariant.default_,
    this.glow = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    List<Color> gradientColors;
    Color glowColor;

    switch (variant) {
      case AuraCardVariant.ai:
        borderColor = AppColors.primary.withAlpha((0.3 * 255).round());
        gradientColors = [
          AppColors.primary.withAlpha((0.1 * 255).round()),
          AppColors.cyan.withAlpha((0.1 * 255).round()),
        ];
        glowColor = AppColors.primaryGlow;
        break;
      case AuraCardVariant.mood:
        borderColor = AppColors.secondary.withAlpha((0.3 * 255).round());
        gradientColors = [
          AppColors.secondary.withAlpha((0.1 * 255).round()),
          AppColors.secondary.withAlpha((0.05 * 255).round()),
        ];
        glowColor = AppColors.secondaryGlow;
        break;
      case AuraCardVariant.nutrition:
        borderColor = AppColors.nutritionColor.withAlpha((0.3 * 255).round());
        gradientColors = [
          AppColors.nutritionColor.withAlpha((0.1 * 255).round()),
          AppColors.nutritionColor.withAlpha((0.05 * 255).round()),
        ];
        glowColor = AppColors.nutritionColor.withAlpha((0.3 * 255).round());
        break;
      case AuraCardVariant.spiritual:
        borderColor = AppColors.spiritualColor.withAlpha((0.3 * 255).round());
        gradientColors = [
          AppColors.spiritualColor.withAlpha((0.1 * 255).round()),
          AppColors.spiritualColor.withAlpha((0.05 * 255).round()),
        ];
        glowColor = AppColors.spiritualColor.withAlpha((0.3 * 255).round());
        break;
      default:
        borderColor = AppColors.primary.withAlpha((0.2 * 255).round());
        gradientColors = [
          AppColors.primary.withAlpha((0.1 * 255).round()),
          AppColors.secondary.withAlpha((0.1 * 255).round()),
        ];
        glowColor = AppColors.primaryGlow;
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ]
            : [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
  }
}

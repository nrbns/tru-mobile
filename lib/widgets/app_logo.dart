import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// TruResetX Logo Widget
///
/// Displays the TruResetX logo in SVG format with optional size customization
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      // If color is specified, we need to apply it as a color filter
      return SvgPicture.asset(
        'assets/icons/truresetx_logo.svg',
        width: width,
        height: height,
        fit: fit,
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }

    return SvgPicture.asset(
      'assets/icons/truresetx_logo.svg',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// TruResetX Logo with PNG fallback
///
/// Uses PNG image for better compatibility where SVG might not render well
class AppLogoPng extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogoPng({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/truresetx_logo.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

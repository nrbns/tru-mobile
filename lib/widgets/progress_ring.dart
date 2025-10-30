import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0-100
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? backgroundColor;
  final bool showPercentage;
  final String? label;
  final bool glow;
  final IconData? icon;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.color = const Color(0xFF3B8AFF),
    this.backgroundColor,
    this.showPercentage = true,
    this.label,
    this.icon,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = (size - strokeWidth) / 2;
    final circumference = radius * 2 * math.pi;
    final offset = circumference - (progress / 100) * circumference;

    return Container(
      width: size,
      height: size,
      decoration: glow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha((0.5 * 255).round()),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            )
          : null,
      child: Stack(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: progress,
                radius: radius,
                strokeWidth: strokeWidth,
                color: color,
                backgroundColor:
                    backgroundColor ?? color.withAlpha((0.1 * 255).round()),
                offset: offset,
                circumference: circumference,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: size * 0.18),
                  const SizedBox(height: 4),
                ],
                if (showPercentage)
                  Text(
                    '${progress.round()}%',
                    style: TextStyle(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontFamily: 'Poppins',
                    ),
                  ),
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: size * 0.08,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final double offset;
  final double circumference;

  _ProgressRingPainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
    required this.offset,
    required this.circumference,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      (progress / 100) * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

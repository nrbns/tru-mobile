import 'package:flutter/material.dart';

/// A simple skeleton loader used as a lightweight placeholder for loading UI.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.color,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Use the newer surfaceContainerHighest token instead of deprecated surfaceVariant
    final bg = color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: padding,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

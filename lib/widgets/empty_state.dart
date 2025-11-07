import 'package:flutter/material.dart';
import '../core/utils/lucide_compat.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? LucideIcons.sparkles, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[300], fontSize: 16)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
          if (action != null) ...[
            const SizedBox(height: 12),
            action!,
          ],
        ],
      ),
    );
  }
}

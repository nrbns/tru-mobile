import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/utils/lucide_compat.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[300], fontSize: 16)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

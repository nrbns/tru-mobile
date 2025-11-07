import 'package:flutter/material.dart';

/// Reusable empty state widget for screens with no data
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for lists
class EmptyListState extends StatelessWidget {
  const EmptyListState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'No items yet',
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Empty state for logs
class EmptyLogsState extends StatelessWidget {
  const EmptyLogsState({
    super.key,
    required this.logType,
    this.onAction,
  });

  final String logType;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: 'No $logType logs yet',
      message: 'Start tracking your $logType to see your progress over time.',
      actionLabel: 'Add $logType',
      onAction: onAction,
    );
  }
}

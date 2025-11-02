import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/agentic_providers.dart';

/// Karma Badge Widget - Shows karma points with animation
class KarmaBadge extends ConsumerWidget {
  const KarmaBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karmaAsync = ref.watch(karmaStatusProvider);

    return karmaAsync.when(
      data: (karma) => GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/agent/karma'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const SizedBox(width: 6),
              Text(
                '${karma.currentKarma}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Lv${karma.level}',
                style: TextStyle(
                  color: Colors.orange.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class CoachInboxScreen extends StatelessWidget {
  const CoachInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {
        'title': 'Weekly Check-in',
        'preview': 'How did your week go? I noticed...',
        'time': '2 hours ago',
        'read': false,
      },
      {
        'title': 'Mood Pattern Alert',
        'preview': 'I detected an interesting pattern...',
        'time': 'Yesterday',
        'read': false,
      },
      {
        'title': 'Congratulations!',
        'preview': 'You\'ve completed 7 days of meditation!',
        'time': '3 days ago',
        'read': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coach Inbox',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Messages from your AI coach',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AuraCard(
                      variant: (message['read'] as bool)
                          ? AuraCardVariant.default_
                          : AuraCardVariant.ai,
                      glow: !(message['read'] as bool),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            gradient: AppColors.aiGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.brain,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          message['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: (message['read'] as bool)
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              message['preview'] as String,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['time'] as String,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: !(message['read'] as bool)
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        onTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

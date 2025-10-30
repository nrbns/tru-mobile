import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _dailyReminders = true;
  bool _streakAlerts = true;
  bool _aiTips = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: _dailyReminders,
            onChanged: (v) => setState(() => _dailyReminders = v),
            title: const Text('Daily reminders', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Motivation and check-ins', style: TextStyle(color: Colors.grey)),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _streakAlerts,
            onChanged: (v) => setState(() => _streakAlerts = v),
            title: const Text('Streak alerts', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Celebrate milestones and prevent drops', style: TextStyle(color: Colors.grey)),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _aiTips,
            onChanged: (v) => setState(() => _aiTips = v),
            title: const Text('AI tips', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Personalized suggestions', style: TextStyle(color: Colors.grey)),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}



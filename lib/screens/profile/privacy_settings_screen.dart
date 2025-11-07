import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

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
        title: const Text('Privacy', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Data usage', style: TextStyle(color: Colors.white)),
            subtitle: Text('We use your data to personalize your experience.',
                style: TextStyle(color: Colors.grey)),
          ),
          Divider(color: AppColors.border),
          ListTile(
            title:
                Text('Delete account', style: TextStyle(color: Colors.white)),
            subtitle: Text('Request account deletion via support.',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

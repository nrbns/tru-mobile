import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfilePersonalizationScreen extends StatelessWidget {
  const ProfilePersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile & Personalization'),
          backgroundColor: AppColors.surface),
      body: const Center(
          child: Text('Profile / Personalization (work in progress)')),
    );
  }
}

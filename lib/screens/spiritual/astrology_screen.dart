import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AstrologyScreen extends StatelessWidget {
  const AstrologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Astrology Insights'),
          backgroundColor: AppColors.surface),
      body: const Center(child: Text('Astrology Insights (work in progress)')),
    );
  }
}

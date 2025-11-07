import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Spiritual Planner'),
          backgroundColor: AppColors.surface),
      body: const Center(child: Text('Planner / Schedule (work in progress)')),
    );
  }
}

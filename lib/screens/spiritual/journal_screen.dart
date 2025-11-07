import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Journal'), backgroundColor: AppColors.surface),
      body: const Center(
          child: Text('Journal / Reflection screen (work in progress)')),
    );
  }
}

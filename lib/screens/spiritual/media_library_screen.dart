import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MediaLibraryScreen extends StatelessWidget {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Media Library'),
          backgroundColor: AppColors.surface),
      body:
          const Center(child: Text('Audio / Video Library (work in progress)')),
    );
  }
}

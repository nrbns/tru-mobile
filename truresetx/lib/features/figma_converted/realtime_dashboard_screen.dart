import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RealTimeDashboardScreen extends StatelessWidget {
  const RealTimeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Dashboard'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Live Mood',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // Placeholder for a realtime mood indicator
              CircleAvatar(
                  radius: 44,
                  child: Text('😊', style: TextStyle(fontSize: 32))),
              const SizedBox(height: 16),
              const Text('Live metrics and streaming charts will appear here.'),
            ],
          ),
        ),
      ),
    );
  }
}

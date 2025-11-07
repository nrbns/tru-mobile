import 'package:flutter/material.dart';
// flutter_riverpod import removed — not used in this file
import '../live/mood_tracking_live.dart';
import '../live/sleep_tracking_live.dart';
import '../live/meal_logging_live.dart';

class RealtimeDashboard extends StatelessWidget {
  final String userId;
  const RealtimeDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Realtime Dashboard'),
          bottom: TabBar(tabs: [
            Tab(text: 'Mood'),
            Tab(text: 'Sleep'),
            Tab(text: 'Meals')
          ]),
        ),
        body: TabBarView(children: [
          MoodTrackingLive(userId: userId),
          SleepTrackingLive(userId: userId),
          MealLoggingLive(userId: userId)
        ]),
      ),
    );
  }
}

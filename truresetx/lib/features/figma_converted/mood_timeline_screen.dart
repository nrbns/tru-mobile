import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoodTimelineScreen extends StatelessWidget {
  const MoodTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Timeline'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final time = DateTime.now().subtract(Duration(hours: index * 3));
          return ListTile(
            leading:
                CircleAvatar(child: Text(['😴', '🙂', '😊', '😃'][index % 4])),
            title: Text('Mood entry #${index + 1}'),
            subtitle: Text('Recorded at ${time.toLocal()}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: 10,
      ),
    );
  }
}

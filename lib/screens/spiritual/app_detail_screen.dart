import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_item.dart';
import '../../theme/app_colors.dart';

class AppDetailScreen extends StatelessWidget {
  final String appId;
  const AppDetailScreen({super.key, required this.appId});

  Future<AppItem?> _loadApp() async {
    final doc =
        await FirebaseFirestore.instance.collection('apps').doc(appId).get();
    if (!doc.exists) return null;
    return AppItem.fromDoc(doc);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppItem?>(
      future: _loadApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final app = snapshot.data;
        if (app == null) {
          return const Scaffold(
              body: Center(
                  child: Text('App not found',
                      style: TextStyle(color: Colors.white))));
        }
        return Scaffold(
          appBar:
              AppBar(title: Text(app.name), backgroundColor: AppColors.surface),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (app.iconUrl.isNotEmpty)
                  Image.network(app.iconUrl, height: 140),
                const SizedBox(height: 12),
                Text(app.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(app.description,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: app.focus.map((f) => Chip(label: Text(f))).toList(),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Try now')));
                        },
                        child: const Text('Try Now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to Journey')));
                      },
                      child: const Text('Add to Journey'),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

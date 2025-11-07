import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/spiritual_provider.dart';
import '../../models/app_item.dart';
import '../../theme/app_colors.dart';

class SpiritHomeScreen extends ConsumerWidget {
  const SpiritHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(spiritualAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Apps'),
        backgroundColor: AppColors.surface,
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(child: Text('No spiritual apps found'));
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return _AppCard(app: app);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load apps: $e')),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final AppItem app;
  const _AppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Map app IDs to routes
        final routeMap = {
          'wisdom-legends': '/spirit/wisdom-legends',
          'mantras': '/spirit/mantras',
          'audio-player': '/spirit/audio-player',
          'rituals': '/spirit/rituals',
          'calendar': '/spirit/calendar',
          'wisdom-feed': '/spirit/wisdom-feed',
          'daily-practice': '/spirit/daily-practice',
        };
        final route = routeMap[app.id] ?? '/spirit/${app.id}';
        context.push(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (app.iconUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(app.iconUrl,
                    height: 84, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Container(
                height: 84,
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8)),
              ),
            const SizedBox(height: 8),
            Text(app.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(app.type,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(app.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    final routeMap = {
                      'wisdom-legends': '/spirit/wisdom-legends',
                      'mantras': '/spirit/mantras',
                      'audio-player': '/spirit/audio-player',
                      'rituals': '/spirit/rituals',
                      'calendar': '/spirit/calendar',
                      'wisdom-feed': '/spirit/wisdom-feed',
                      'daily-practice': '/spirit/daily-practice',
                    };
                    final route = routeMap[app.id] ?? '/spirit/${app.id}';
                    context.push(route);
                  },
                  child: const Text('Open'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

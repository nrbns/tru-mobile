import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/list_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Text(
                        'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Wellness Enthusiast',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Member since ${DateTime.now().year}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Wellness Stats
            Text(
              'Your Wellness Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  'Total Lists',
                  '${lists.length}',
                  Icons.list_alt,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Active Items',
                  '${_getTotalActiveItems(lists)}',
                  Icons.task_alt,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Completed Items',
                  '${_getTotalCompletedItems(lists)}',
                  Icons.check_circle,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Completion Rate',
                  '${_getOverallCompletionRate(lists).toInt()}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category Breakdown
            Text(
              'Category Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._buildCategoryProgressCards(context, lists),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildActionTile(
                  context,
                  'Export Data',
                  'Download your wellness data',
                  Icons.download,
                  () {
                    // TODO: Implement data export
                  },
                ),
                _buildActionTile(
                  context,
                  'Backup & Sync',
                  'Sync your data across devices',
                  Icons.cloud_sync,
                  () {
                    // TODO: Implement backup
                  },
                ),
                _buildActionTile(
                  context,
                  'Share Progress',
                  'Share your wellness journey',
                  Icons.share,
                  () {
                    // TODO: Implement sharing
                  },
                ),
                _buildActionTile(
                  context,
                  'Settings',
                  'Customize your experience',
                  Icons.settings,
                  () {
                    // TODO: Implement settings
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _buildCategoryProgressCards(BuildContext context, lists) {
    final categories = [
      {'name': 'Fitness', 'icon': '💪', 'color': Colors.red},
      {'name': 'Nutrition', 'icon': '🥗', 'color': Colors.green},
      {'name': 'Mental Health', 'icon': '🧠', 'color': Colors.blue},
      {'name': 'Spiritual', 'icon': '✨', 'color': Colors.purple},
      {'name': 'Habits', 'icon': '🔄', 'color': Colors.orange},
      {'name': 'Goals', 'icon': '🎯', 'color': Colors.pink},
    ];

    return categories.map((category) {
      final categoryLists = lists
          .where((list) => list.category
              .toString()
              .split('.')
              .last
              .toLowerCase()
              .contains((category['name'] as String)
                  .toLowerCase()
                  .replaceAll(' ', '')))
          .toList();

      final totalItems =
          categoryLists.fold(0, (sum, list) => sum + list.totalCount);
      final completedItems =
          categoryLists.fold(0, (sum, list) => sum + list.completedCount);
      final completionRate = totalItems > 0 ? completedItems / totalItems : 0.0;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: category['color'] as Color,
            child: Text(
              category['icon'] as String,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          title: Text(category['name'] as String),
          subtitle: Text('$completedItems/$totalItems completed'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  category['color'] as Color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(completionRate * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: category['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  int _getTotalActiveItems(lists) {
    return lists.fold(
        0,
        (sum, list) =>
            sum + list.items.where((item) => !item.isCompleted).length);
  }

  int _getTotalCompletedItems(lists) {
    return lists.fold(0, (sum, list) => sum + list.completedCount);
  }

  double _getOverallCompletionRate(lists) {
    final totalItems = lists.fold(0, (sum, list) => sum + list.totalCount);
    final completedItems =
        lists.fold(0, (sum, list) => sum + list.completedCount);
    return totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;
  }
}

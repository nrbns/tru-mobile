// profile_screen_realtime.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'realtime_providers.dart'; // adjust path to your file

class RealtimeProfileScreen extends ConsumerWidget {
  final String userId;

  const RealtimeProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider(userId));
    final listsAsync = ref.watch(listsStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // trigger remote refresh
          await ref.read(realtimeServiceProvider).refreshLists(userId);
          // also refresh local streams if desired
          ref.invalidate(listsStreamProvider(userId));
          ref.invalidate(userProfileStreamProvider(userId));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile Header (reactive)
              profileAsync.when(
                data: (profile) => _buildProfileHeader(context, ref, profile),
                loading: () => _buildProfileHeaderLoading(context),
                error: (err, st) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                            radius: 40, child: Icon(Icons.person)),
                        const SizedBox(height: 12),
                        Text('Error loading profile',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(err.toString(),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Live Stats (reactive)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Wellness Journey',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              listsAsync.when(
                data: (lists) {
                  final totalLists = lists.length;
                  final totalItems = lists.fold<int>(
                      0, (int s, SimpleListModel l) => s + l.totalCount);
                  final completedItems = lists.fold<int>(
                      0, (int s, SimpleListModel l) => s + l.completedCount);
                  final activeItems = totalItems - completedItems;
                  final completionRate = totalItems > 0
                      ? (completedItems / totalItems) * 100
                      : 0.0;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(context, 'Total Lists', '$totalLists',
                          Icons.list_alt, Colors.blue),
                      _buildStatCard(context, 'Active Items', '$activeItems',
                          Icons.task_alt, Colors.green),
                      _buildStatCard(context, 'Completed Items',
                          '$completedItems', Icons.check_circle, Colors.orange),
                      _buildStatCard(
                          context,
                          'Completion Rate',
                          '${completionRate.toStringAsFixed(0)}%',
                          Icons.trending_up,
                          Colors.purple),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading lists: $e'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Category breakdown (reactive)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Category Progress',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              listsAsync.when(
                data: (lists) => Column(
                    children:
                        _buildCategoryProgressCards(context, lists).toList()),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildActionTile(context, 'Export Data',
                      'Download your wellness data', Icons.download, () {
                    // TODO: export logic
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export started')));
                  }),
                  _buildActionTile(context, 'Backup & Sync',
                      'Sync your data across devices', Icons.cloud_sync, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing...')));
                    ref.read(realtimeServiceProvider).refreshLists(userId);
                  }),
                  _buildActionTile(context, 'Share Progress',
                      'Share your wellness journey', Icons.share, () {
                    // share logic
                  }),
                  _buildActionTile(context, 'Settings',
                      'Customize your experience', Icons.settings, () {
                    // open settings
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, WidgetRef ref, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: () => _showAvatarEditor(context, ref, profile),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: profile.avatarUrl.isEmpty
                        ? Text(
                            profile.displayName.isNotEmpty
                                ? profile.displayName[0]
                                : 'U',
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : ClipOval(
                            child: Image.network(
                              profile.avatarUrl,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 44,
                                  color: Colors.white),
                            ),
                          ),
                  ),
                ),
                // presence dot
                Container(
                  margin: const EdgeInsets.only(right: 2, bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2),
                    color: profile.isOnline ? Colors.green : Colors.grey,
                  ),
                  width: 16,
                  height: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.displayName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              profile.bio,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              profile.isOnline
                  ? 'Online'
                  : 'Last seen: ${_formatLastSeen(profile.lastSeen)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderLoading(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            Text('Loading profile...',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _buildCategoryProgressCards(
      BuildContext context, List<SimpleListModel> lists) {
    final categories = [
      {'name': 'Fitness', 'icon': '💪', 'color': Colors.red},
      {'name': 'Nutrition', 'icon': '🥗', 'color': Colors.green},
      {'name': 'Mental Health', 'icon': '🧠', 'color': Colors.blue},
      {'name': 'Spiritual', 'icon': '✨', 'color': Colors.purple},
      {'name': 'Habits', 'icon': '🔄', 'color': Colors.orange},
      {'name': 'Goals', 'icon': '🎯', 'color': Colors.pink},
    ];

    return categories.map((category) {
      final categoryName = (category['name'] as String).toLowerCase();
      final categoryLists = lists
          .where((list) => list.category.toLowerCase().contains(categoryName))
          .toList();

      final totalItems = categoryLists.fold<int>(
          0, (int sum, SimpleListModel list) => sum + list.totalCount);
      final completedItems = categoryLists.fold<int>(
          0, (int sum, SimpleListModel list) => sum + list.completedCount);
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
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: completionRate,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(category['color'] as Color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(completionRate * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: category['color'] as Color,
                    fontWeight: FontWeight.bold),
              )
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

  void _showAvatarEditor(
      BuildContext context, WidgetRef ref, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () {
                // TODO: open camera and upload -> call your backend to update avatar
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera tapped')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                // TODO: pick image and upload
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery tapped')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove avatar'),
              onTap: () {
                // TODO: call backend to remove avatar
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar removed')));
              },
            )
          ],
        ),
      ),
    );
  }
}

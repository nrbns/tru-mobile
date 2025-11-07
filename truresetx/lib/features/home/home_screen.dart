import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/providers/list_providers.dart';
import '../../data/models/wellness_list.dart';
import '../lists/lists_screen.dart';
import '../lists/list_detail_screen.dart';
import 'today_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('TruResetX'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Your Wellness Journey',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your progress across fitness, nutrition, mental health, and spiritual growth.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today card
            const TodayCard(),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Lists',
                    '${lists.length}',
                    Icons.list_alt,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Items',
                    '${_getTotalActiveItems(lists)}',
                    Icons.task_alt,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Completed Today',
                    '${_getCompletedToday(lists)}',
                    Icons.check_circle,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Streak',
                    '${_getCurrentStreak(lists)}',
                    Icons.local_fire_department,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Lists
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Lists',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ListsScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...lists.take(3).map((list) => _buildListCard(context, list)),
            const SizedBox(height: 24),

            // Category Overview
            Text(
              'Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ListCategory.values.map((category) {
                final categoryLists =
                    lists.where((list) => list.category == category).toList();
                return _buildCategoryChip(
                    context, category, categoryLists.length);
              }).toList(),
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

  Widget _buildListCard(BuildContext context, WellnessList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(list.category),
          child: Text(
            list.icon ?? _getCategoryIcon(list.category),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(list.name),
        subtitle: Text('${list.completedCount}/${list.totalCount} completed'),
        trailing: CircularProgressIndicator(
          value: list.completionPercentage,
          backgroundColor: Colors.grey[300],
        ),
        onTap: () {
          // Navigate to list detail screen using direct route to ensure it works
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListDetailScreen(listId: list.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
      BuildContext context, ListCategory category, int count) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: _getCategoryColor(category),
        child: Text(
          _getCategoryIcon(category),
          style: const TextStyle(fontSize: 16),
        ),
      ),
      label: Text('${_getCategoryName(category)} ($count)'),
      backgroundColor: _getCategoryColor(category).withValues(alpha: 0.1),
    );
  }

  int _getTotalActiveItems(List<WellnessList> lists) {
    return lists.fold(
        0,
        (sum, list) =>
            sum + list.items.where((item) => !item.isCompleted).length);
  }

  int _getCompletedToday(List<WellnessList> lists) {
    final today = DateTime.now();
    return lists.fold(0, (sum, list) {
      return sum +
          list.items.where((item) {
            if (item.completedAt == null) return false;
            final completedDate = item.completedAt!;
            return completedDate.year == today.year &&
                completedDate.month == today.month &&
                completedDate.day == today.day;
          }).length;
    });
  }

  int _getCurrentStreak(List<WellnessList> lists) {
    // Simple streak calculation - in a real app, this would be more sophisticated
    return 7; // Placeholder
  }

  Color _getCategoryColor(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return Colors.red;
      case ListCategory.nutrition:
        return Colors.green;
      case ListCategory.mentalHealth:
        return Colors.blue;
      case ListCategory.spiritual:
        return Colors.purple;
      case ListCategory.habits:
        return Colors.orange;
      case ListCategory.goals:
        return Colors.pink;
      case ListCategory.general:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return '💪';
      case ListCategory.nutrition:
        return '🥗';
      case ListCategory.mentalHealth:
        return '🧠';
      case ListCategory.spiritual:
        return '✨';
      case ListCategory.habits:
        return '🔄';
      case ListCategory.goals:
        return '🎯';
      case ListCategory.general:
        return '📝';
    }
  }

  String _getCategoryName(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return 'Fitness';
      case ListCategory.nutrition:
        return 'Nutrition';
      case ListCategory.mentalHealth:
        return 'Mental Health';
      case ListCategory.spiritual:
        return 'Spiritual';
      case ListCategory.habits:
        return 'Habits';
      case ListCategory.goals:
        return 'Goals';
      case ListCategory.general:
        return 'General';
    }
  }
}

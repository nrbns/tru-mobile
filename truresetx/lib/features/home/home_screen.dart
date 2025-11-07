import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/list_providers.dart';
import '../../data/models/wellness_list.dart';
import 'today_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lists = ref.watch(listsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TruResetX',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today Card with all metrics
                  const TodayCard(),
                  const SizedBox(height: 24),

                  // Quick Actions Section
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionsGrid(),
                  const SizedBox(height: 24),

                  // Discipline Score & Streak
                  _DisciplineSection(),
                  const SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Lists',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/lists'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (lists.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No lists yet',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first wellness list to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/lists/add'),
                                icon: const Icon(Icons.add),
                                label: const Text('Create List'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...lists
                        .take(3)
                        .map((list) => _buildListCard(context, list)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, WellnessList list) {
    final progress = list.completionPercentage;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/lists/detail/${list.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    _getCategoryColor(list.category).withValues(alpha: 0.1),
                child: Text(
                  list.icon ?? _getCategoryIcon(list.category),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${list.completedCount}/${list.totalCount} completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCategoryColor(list.category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
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
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.monitor_weight_outlined,
        label: 'Weight',
        color: Colors.blue,
        route: '/metrics/weight',
      ),
      _QuickAction(
        icon: Icons.restaurant_outlined,
        label: 'Meal',
        color: Colors.green,
        route: '/nutrition/manual',
      ),
      _QuickAction(
        icon: Icons.fitness_center_outlined,
        label: 'Workout',
        color: Colors.red,
        route: '/workout/start',
      ),
      _QuickAction(
        icon: Icons.check_circle_outline,
        label: 'Habit',
        color: Colors.orange,
        route: '/lists',
      ),
      _QuickAction(
        icon: Icons.mood_outlined,
        label: 'Mood',
        color: Colors.purple,
        route: '/mood',
      ),
      _QuickAction(
        icon: Icons.note_add_outlined,
        label: 'Note',
        color: Colors.teal,
        route: '/coach/chat',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(action: action);
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisciplineSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lists = ref.watch(listsProvider);

    // Calculate discipline score (simplified)
    final completedToday = _getCompletedToday(lists);
    final totalHabits = lists
        .where((l) => l.category == ListCategory.habits)
        .fold(0, (sum, list) => sum + list.totalCount);
    final disciplineScore = totalHabits > 0
        ? ((completedToday / totalHabits) * 100).clamp(0, 100).toInt()
        : 0;
    final streak = _getCurrentStreak(lists);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discipline Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak day streak',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$disciplineScore',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(disciplineScore),
                        ),
                      ),
                      Text(
                        'out of 100',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: disciplineScore / 100,
                      minHeight: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(disciplineScore),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
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
}

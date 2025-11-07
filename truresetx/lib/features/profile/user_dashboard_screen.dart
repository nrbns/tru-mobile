import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_profile.dart';

/// User Dashboard Screen with personalized data and insights
class UserDashboardScreen extends ConsumerStatefulWidget {
  const UserDashboardScreen({
    super.key,
    required this.profile,
  });
  final UserProfile profile;

  @override
  ConsumerState<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.profile.fullName.split(' ').first}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          _buildProfileHeader(),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
              Tab(text: 'Health', icon: Icon(Icons.favorite)),
              Tab(text: 'Goals', icon: Icon(Icons.flag)),
              Tab(text: 'Activity', icon: Icon(Icons.trending_up)),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHealthTab(),
                _buildGoalsTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha((0.8 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
            child: widget.profile.hasProfilePicture
                ? ClipOval(
                    child: Image.network(
                      widget.profile.profilePicture!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 40, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.profile.bio != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.profile.bio!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.cake, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.profile.age} years old',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      widget.profile.location ?? 'Location not set',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),

          // Health Summary
          _buildHealthSummary(),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(),
          const SizedBox(height: 24),

          // Goals Progress
          _buildGoalsProgress(),
          const SizedBox(height: 24),

          // Recommendations
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'BMI',
                    widget.profile.bmi.toStringAsFixed(1),
                    widget.profile.bmiCategory,
                    Icons.monitor_weight,
                    _getBMIColor(widget.profile.bmi),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Age',
                    '${widget.profile.age}',
                    'years old',
                    Icons.cake,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Height',
                    '${widget.profile.height.toInt()} cm',
                    '${(widget.profile.height / 2.54).toStringAsFixed(1)} in',
                    Icons.height,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Weight',
                    '${widget.profile.weight.toInt()} kg',
                    '${(widget.profile.weight * 2.205).toStringAsFixed(1)} lbs',
                    Icons.fitness_center,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color.withAlpha((0.7 * 255).round()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildHealthSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHealthItem('Activity Level',
                widget.profile.activityLevelDescription, Icons.fitness_center),
            const SizedBox(height: 12),
            _buildHealthItem(
                'Dietary Restrictions',
                widget.profile.dietaryRestrictionNames.join(', '),
                Icons.restaurant),
            const SizedBox(height: 12),
            _buildHealthItem(
                'Medical Conditions',
                widget.profile.medicalConditionNames.join(', '),
                Icons.medical_services),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.isEmpty ? 'None' : value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityItem('Last Workout', '2 days ago',
                Icons.fitness_center, Colors.green),
            const SizedBox(height: 12),
            _buildActivityItem('Last Meal Logged', '4 hours ago',
                Icons.restaurant, Colors.orange),
            const SizedBox(height: 12),
            _buildActivityItem(
                'Last Mood Check', '1 day ago', Icons.mood, Colors.purple),
            const SizedBox(height: 12),
            _buildActivityItem(
                'Last Meditation', '3 days ago', Icons.spa, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.profile.fitnessGoals.isEmpty)
              const Text(
                'No goals set yet. Add some goals to track your progress!',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...widget.profile.fitnessGoals.map((goal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            goal.isActive ? 'Active' : 'Paused',
                            style: TextStyle(
                              color: goal.isActive ? Colors.green : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.3, // Mock progress
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Complete your profile',
              'Add a profile picture and bio to personalize your experience',
              Icons.person_add,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Set your first goal',
              'Create a fitness goal to start tracking your progress',
              Icons.flag,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Log your first workout',
              'Start tracking your fitness journey with a workout',
              Icons.fitness_center,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
      String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI Chart
          _buildBMIChart(),
          const SizedBox(height: 24),

          // Health Metrics
          _buildHealthMetrics(),
          const SizedBox(height: 24),

          // Medical Information
          _buildMedicalInformation(),
        ],
      ),
    );
  }

  Widget _buildBMIChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    widget.profile.bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getBMIColor(widget.profile.bmi),
                    ),
                  ),
                  Text(
                    widget.profile.bmiCategory,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getBMIColor(widget.profile.bmi),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBMIRange(),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIRange() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Underweight',
                style: TextStyle(fontSize: 12, color: Colors.blue)),
            Text('Normal', style: TextStyle(fontSize: 12, color: Colors.green)),
            Text('Overweight',
                style: TextStyle(fontSize: 12, color: Colors.orange)),
            Text('Obese', style: TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
              stops: [0.0, 0.25, 0.5, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('18.5',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('25', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('30', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricItem(
                'Height', '${widget.profile.height.toInt()} cm', Icons.height),
            _buildMetricItem('Weight', '${widget.profile.weight.toInt()} kg',
                Icons.fitness_center),
            _buildMetricItem('Age', '${widget.profile.age} years', Icons.cake),
            _buildMetricItem('Activity Level',
                widget.profile.activityLevelDescription, Icons.directions_run),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.profile.dietaryRestrictions.isNotEmpty) ...[
              _buildInfoSection(
                  'Dietary Restrictions', widget.profile.dietaryRestrictions),
              const SizedBox(height: 16),
            ],
            if (widget.profile.medicalConditions.isNotEmpty) ...[
              _buildInfoSection(
                  'Medical Conditions', widget.profile.medicalConditions),
              const SizedBox(height: 16),
            ],
            // Emergency contact
            _buildEmergencyContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Chip(
              label: Text(item.name),
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactInfo() {
    final contact = widget.profile.emergencyContact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Contact',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.emergency),
            title: Text(contact.name),
            subtitle: Text('${contact.relationship} - ${contact.phoneNumber}'),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goals Overview
          _buildGoalsOverview(),
          const SizedBox(height: 24),

          // Active Goals
          _buildActiveGoals(),
          const SizedBox(height: 24),

          // Goal Categories
          _buildGoalCategories(),
        ],
      ),
    );
  }

  Widget _buildGoalsOverview() {
    final activeGoals =
        widget.profile.fitnessGoals.where((goal) => goal.isActive).length;
    final totalGoals = widget.profile.fitnessGoals.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGoalStat(
                      'Active Goals', '$activeGoals', Icons.flag, Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGoalStat(
                      'Total Goals', '$totalGoals', Icons.list, Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoals() {
    final activeGoals =
        widget.profile.fitnessGoals.where((goal) => goal.isActive).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (activeGoals.isEmpty)
              const Text(
                'No active goals. Create your first goal to get started!',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...activeGoals.map((goal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.green.withAlpha((0.1 * 255).round()),
                        child: const Icon(Icons.flag, color: Colors.green),
                      ),
                      title: Text(goal.name),
                      subtitle: Text(
                          goal.category.replaceAll('_', ' ').toUpperCase()),
                      trailing: Text(
                        'Priority ${goal.priority}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCategories() {
    final categories = widget.profile.fitnessGoals
        .map((goal) => goal.category)
        .toSet()
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final count = widget.profile.fitnessGoals
                    .where((goal) => goal.category == category)
                    .length;
                return Chip(
                  label: Text(
                      '${category.replaceAll('_', ' ').toUpperCase()} ($count)'),
                  backgroundColor: Colors.blue.withAlpha((0.1 * 255).round()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Summary
          _buildActivitySummary(),
          const SizedBox(height: 24),

          // Weekly Activity
          _buildWeeklyActivity(),
          const SizedBox(height: 24),

          // Achievements
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActivityStat('Workouts', '3', 'this week',
                      Icons.fitness_center, Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActivityStat('Meals Logged', '12', 'this week',
                      Icons.restaurant, Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActivityStat('Mood Checks', '5', 'this week',
                      Icons.mood, Colors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActivityStat(
                      'Meditations', '2', 'this week', Icons.spa, Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(
      String label, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color.withAlpha((0.7 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Activity chart would go here',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Activity Chart Placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAchievementItem(
              'First Workout',
              'Completed your first workout!',
              Icons.fitness_center,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildAchievementItem(
              'Profile Complete',
              'Completed your profile setup',
              Icons.person,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildAchievementItem(
              'Goal Setter',
              'Set your first fitness goal',
              Icons.flag,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
      String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editProfile() {
    // Navigate to profile edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile editing not implemented yet')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        // Navigate to settings
        break;
      case 'logout':
        // Handle logout
        break;
    }
  }
}


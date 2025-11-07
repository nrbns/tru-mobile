// realtime_user_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_profile.dart';
import '../../core/services/realtime_profile_service.dart';
import 'profile_setup_screen.dart';

/// Realtime User Dashboard - subscribes to userProfileStreamProvider(userId)
class RealtimeUserDashboard extends ConsumerStatefulWidget {
  final String userId;

  const RealtimeUserDashboard({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<RealtimeUserDashboard> createState() =>
      _RealtimeUserDashboardState();
}

class _RealtimeUserDashboardState extends ConsumerState<RealtimeUserDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // mark presence online when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(realtimeProfileServiceProvider).setPresence(widget.userId, true);
    });
  }

  @override
  void dispose() {
    // mark presence offline when leaving (optionally)
    ref.read(realtimeProfileServiceProvider).setPresence(widget.userId, false);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider(widget.userId));

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(child: Text('Error loading profile: $err')),
      ),
      data: (profile) => _buildDashboardForProfile(context, profile),
    );
  }

  Widget _buildDashboardForProfile(BuildContext context, UserProfile profile) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_displayFirstName(profile.fullName)}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // presence indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
            child: Row(
              children: [
                _presenceDot(profile),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _refreshProfile(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  onPressed: () => _editProfile(profile),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header (uses the live profile)
          _buildProfileHeader(profile),

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
                _buildOverviewTab(profile),
                _buildHealthTab(profile),
                _buildGoalsTab(profile),
                _buildActivityTab(profile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'User';
    return fullName.trim().split(' ').first;
  }

  Widget _presenceDot(UserProfile profile) {
    // Prefer lastActiveAt if available on your model. Consider "online" if
    // lastActiveAt is recent (within 60s). Fallback to false.
    final last = profile.lastActiveAt;
    final isOnline =
        last != null && DateTime.now().difference(last).inSeconds < 60;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor, width: 2),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
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
            child: profile.hasProfilePicture
                ? ClipOval(
                    child: Image.network(
                      profile.profilePicture!,
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
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.bio!,
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
                      '${profile.age} years old',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile.location ?? 'Location not set',
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  // Below: re-used UI code from your dashboard but now accepts a live profile param
  Widget _buildOverviewTab(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(profile),
          const SizedBox(height: 24),
          _buildHealthSummary(profile),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildGoalsProgress(profile),
          const SizedBox(height: 24),
          _buildRecommendations(profile),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'BMI',
                    profile.bmi.toStringAsFixed(1),
                    profile.bmiCategory,
                    Icons.monitor_weight,
                    _getBMIColor(profile.bmi),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Age',
                    '${profile.age}',
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
                    '${profile.height.toInt()} cm',
                    '${(profile.height / 2.54).toStringAsFixed(1)} in',
                    Icons.height,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Weight',
                    '${profile.weight.toInt()} kg',
                    '${(profile.weight * 2.205).toStringAsFixed(1)} lbs',
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
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10, color: color.withAlpha((0.7 * 255).round()))),
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

  Widget _buildHealthSummary(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Health Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildHealthItem('Activity Level', profile.activityLevelDescription,
                Icons.fitness_center),
            const SizedBox(height: 12),
            _buildHealthItem('Dietary Restrictions',
                profile.dietaryRestrictionNames.join(', '), Icons.restaurant),
            const SizedBox(height: 12),
            _buildHealthItem(
                'Medical Conditions',
                profile.medicalConditionNames.join(', '),
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text(value.isEmpty ? 'None' : value,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
            const Text('Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActivityItem('Last Workout', '2 days ago',
                Icons.fitness_center, Colors.green),
            const SizedBox(height: 12),
            _buildActivityItem('Last Meal Logged', '4 hours ago',
                Icons.restaurant, Colors.orange),
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
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600]))
        ])),
      ],
    );
  }

  Widget _buildGoalsProgress(UserProfile profile) {
    final goals = profile.fitnessGoals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goals Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (goals.isEmpty)
              const Text(
                  'No goals set yet. Add some goals to track your progress!',
                  style: TextStyle(color: Colors.grey))
            else
              ...goals.map((goal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(goal.isActive ? 'Active' : 'Paused',
                                style: TextStyle(
                                    color: goal.isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    fontSize: 12))
                          ]),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                          value: 0.0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              goal.isActive ? Colors.green : Colors.grey)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRecommendationItem(
                'Complete your profile',
                'Add a profile picture and bio to personalize your experience',
                Icons.person_add,
                Colors.blue),
            const SizedBox(height: 12),
            _buildRecommendationItem(
                'Set your first goal',
                'Create a fitness goal to start tracking your progress',
                Icons.flag,
                Colors.green),
            const SizedBox(height: 12),
            _buildRecommendationItem(
                'Log your first workout',
                'Start tracking your fitness journey with a workout',
                Icons.fitness_center,
                Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
      String title, String description, IconData icon, Color color) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]))
      ])),
    ]);
  }

  Widget _buildHealthTab(UserProfile profile) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildBMIChart(profile),
          const SizedBox(height: 24),
          _buildHealthMetrics(profile),
          const SizedBox(height: 24),
          _buildMedicalInformation(profile)
        ]));
  }

  Widget _buildBMIChart(UserProfile profile) {
    final bmi = profile.bmi;
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('BMI Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Center(
                child: Column(children: [
              Text(bmi.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getBMIColor(bmi))),
              Text(profile.bmiCategory,
                  style: TextStyle(fontSize: 16, color: _getBMIColor(bmi)))
            ])),
            const SizedBox(height: 16),
            _buildBMIRange()
          ])),
    );
  }

  Widget _buildBMIRange() {
    return Column(children: []);
  }

  Widget _buildHealthMetrics(UserProfile profile) {
    return Card(child: Container());
  }

  Widget _buildMedicalInformation(UserProfile profile) {
    return Card(child: Container());
  }

  Widget _buildGoalsTab(UserProfile profile) {
    return SingleChildScrollView(child: Container());
  }

  Widget _buildActivityTab(UserProfile profile) {
    return SingleChildScrollView(child: Container());
  }

  // ---- Actions ----
  void _editProfile(UserProfile profile) {
    // open the setup screen in edit mode (prefilled via realtime service or passed profile)
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              ProfileSetupScreen(userId: profile.id, email: profile.email)),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        // TODO: navigate to settings
        break;
      case 'logout':
        // TODO: perform logout (and set presence offline)
        ref
            .read(realtimeProfileServiceProvider)
            .setPresence(widget.userId, false);
        break;
    }
  }

  Future<void> _refreshProfile() async {
    final service = ref.read(realtimeProfileServiceProvider);
    try {
      // Trigger a re-emit / refresh on the mock service
      await service.setPresence(widget.userId, true);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Refreshed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Refresh failed: $e')));
      }
    }
  }
}

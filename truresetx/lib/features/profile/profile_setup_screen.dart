import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_profile.dart';
// auth_service import removed (unused)
import 'realtime_user_dashboard.dart';
import '../../core/services/realtime_profile_service.dart';

/// Profile Setup Screen for new users
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.userId,
    required this.email,
  });
  final String userId;
  final String email;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();

  // Profile data
  DateTime? _dateOfBirth;
  Gender? _gender;
  double _height = 170.0; // cm
  double _weight = 70.0; // kg
  ActivityLevel? _activityLevel;
  final List<FitnessGoal> _fitnessGoals = [];
  final List<DietaryRestriction> _dietaryRestrictions = [];
  final List<MedicalCondition> _medicalConditions = [];
  EmergencyContact? _emergencyContact;
  String _preferredWorkoutTime = 'morning';
  String _timezone = 'UTC';
  String _language = 'en';
  NotificationSettings? _notificationSettings;
  PrivacySettings? _privacySettings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
    _initializeDefaultSettings();
    // Prefill fields if a realtime profile exists
    _prefillFromRealtime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _pageController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  // Presence handling: update backend when app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final service = ref.read(realtimeProfileServiceProvider);
    if (state == AppLifecycleState.resumed) {
      service.setPresence(widget.userId, true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      service.setPresence(widget.userId, false);
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _prefillFromRealtime() async {
    try {
      final service = ref.read(realtimeProfileServiceProvider);
      final sub =
          service.profileStream(widget.userId).take(1).listen((profile) {
        if (mounted) {
          setState(() {
            // Use non-nullable model fields directly; keep guards for truly nullable
            _fullNameController.text = profile.fullName;
            _bioController.text = profile.bio ?? '';
            _locationController.text = profile.location ?? '';
            _occupationController.text = profile.occupation ?? '';
            _dateOfBirth = profile.dateOfBirth;
            _gender = profile.gender;
            _height = profile.height;
            _weight = profile.weight;
            _activityLevel = profile.activityLevel;
            _preferredWorkoutTime = profile.preferredWorkoutTime;
            _timezone = profile.timezone;
            _language = profile.language;
            _notificationSettings = profile.notificationSettings;
            _privacySettings = profile.privacySettings;
          });
        }
      });
      await sub.asFuture();
    } catch (_) {
      // ignore - prefill is optional
    }
  }

  void _initializeDefaultSettings() {
    _notificationSettings = NotificationSettings(
      workoutReminders: true,
      mealReminders: true,
      moodCheckIns: true,
      meditationReminders: true,
      achievementCelebrations: true,
      weeklyReports: true,
      promotionalEmails: false,
      pushNotifications: true,
      emailNotifications: true,
      reminderTime: '09:00',
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
    );

    _privacySettings = PrivacySettings(
      profileVisibility: 'private',
      activitySharing: false,
      dataSharing: false,
      locationSharing: false,
      healthDataSharing: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Profile (${_currentStep + 1}/4)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Tab bar
          TabBar(
            controller: _tabController,
            onTap: (index) => _goToStep(index),
            tabs: const [
              Tab(text: 'Basic Info', icon: Icon(Icons.person)),
              Tab(text: 'Health', icon: Icon(Icons.favorite)),
              Tab(text: 'Goals', icon: Icon(Icons.flag)),
              Tab(text: 'Settings', icon: Icon(Icons.settings)),
            ],
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildHealthTab(),
                _buildGoalsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: (_currentStep + 1) / 4,
        backgroundColor: Colors.grey[300],
        valueColor:
            AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us personalize your experience',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Profile picture
          _buildProfilePictureSection(),
          const SizedBox(height: 24),

          // Full name
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Date of birth
          _buildDateOfBirthField(),
          const SizedBox(height: 16),

          // Gender
          _buildGenderField(),
          const SizedBox(height: 16),

          // Bio
          _buildTextField(
            controller: _bioController,
            label: 'Bio (Optional)',
            hint: 'Tell us about yourself...',
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Location
          _buildTextField(
            controller: _locationController,
            label: 'Location (Optional)',
            hint: 'City, Country',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 16),

          // Occupation
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation (Optional)',
            hint: 'What do you do?',
            icon: Icons.work,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us provide better recommendations',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Height and Weight
          Row(
            children: [
              Expanded(
                child: _buildHeightField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeightField(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // BMI Display
          _buildBMIDisplay(),
          const SizedBox(height: 24),

          // Activity Level
          _buildActivityLevelField(),
          const SizedBox(height: 24),

          // Dietary Restrictions
          _buildDietaryRestrictionsField(),
          const SizedBox(height: 24),

          // Medical Conditions
          _buildMedicalConditionsField(),
          const SizedBox(height: 24),

          // Emergency Contact
          _buildEmergencyContactField(),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Goals',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'What do you want to achieve?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Fitness Goals
          _buildFitnessGoalsField(),
          const SizedBox(height: 24),

          // Preferred Workout Time
          _buildWorkoutTimeField(),
          const SizedBox(height: 24),

          // Interests
          _buildInterestsField(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your experience',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Notification Settings
          _buildNotificationSettings(),
          const SizedBox(height: 24),

          // Privacy Settings
          _buildPrivacySettings(),
          const SizedBox(height: 24),

          // Language and Timezone
          _buildLanguageTimezoneFields(),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _selectProfilePicture,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: isRequired
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildDateOfBirthField() {
    return InkWell(
      onTap: _selectDateOfBirth,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          _dateOfBirth != null
              ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
              : 'Select your date of birth',
          style: TextStyle(
            color: _dateOfBirth != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Gender.values.map((gender) {
            return ChoiceChip(
              label: Text(gender.name),
              selected: _gender == gender,
              onSelected: (selected) {
                setState(() {
                  _gender = selected ? gender : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Height (cm)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Slider(
          value: _height,
          min: 100,
          max: 250,
          divisions: 150,
          label: '${_height.toInt()} cm',
          onChanged: (value) {
            setState(() {
              _height = value;
            });
          },
        ),
        Text(
            '${_height.toInt()} cm (${(_height / 2.54).toStringAsFixed(1)} in)'),
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weight (kg)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Slider(
          value: _weight,
          min: 30,
          max: 200,
          divisions: 170,
          label: '${_weight.toInt()} kg',
          onChanged: (value) {
            setState(() {
              _weight = value;
            });
          },
        ),
        Text(
            '${_weight.toInt()} kg (${(_weight * 2.205).toStringAsFixed(1)} lbs)'),
      ],
    );
  }

  Widget _buildBMIDisplay() {
    final bmi = _weight / ((_height / 100) * (_height / 100));
    String category;
    Color color;

    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal weight';
      color = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange;
    } else {
      category = 'Obese';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('BMI',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text(bmi.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              Text('Category',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text(category, style: TextStyle(fontSize: 16, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activity Level',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        // Use a DropdownButton for activity level to avoid deprecated Radio API.
        DropdownButton<ActivityLevel>(
          value: _activityLevel,
          isExpanded: true,
          items: ActivityLevel.values
              .map((level) => DropdownMenuItem(
                    value: level,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(level.name.replaceAll('_', ' ').toUpperCase()),
                        const SizedBox(height: 4),
                        Text(
                          _getActivityLevelDescription(level),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _activityLevel = value;
            });
          },
        ),
      ],
    );
  }

  String _getActivityLevelDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Little to no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Heavy exercise 6-7 days/week';
      case ActivityLevel.extraActive:
        return 'Very heavy exercise, physical job';
    }
  }

  Widget _buildDietaryRestrictionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dietary Restrictions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Vegetarian',
            'Vegan',
            'Gluten-Free',
            'Dairy-Free',
            'Nut Allergy',
            'Lactose Intolerant',
            'Keto',
            'Paleo',
            'Halal',
            'Kosher'
          ].map((restriction) {
            final isSelected =
                _dietaryRestrictions.any((r) => r.name == restriction);
            return FilterChip(
              label: Text(restriction),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _dietaryRestrictions.add(DietaryRestriction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: restriction,
                      type: 'preference',
                      severity: 'mild',
                    ));
                  } else {
                    _dietaryRestrictions
                        .removeWhere((r) => r.name == restriction);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicalConditionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Medical Conditions (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        const Text(
            'Please consult with your healthcare provider before starting any fitness program'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Diabetes',
            'Hypertension',
            'Heart Disease',
            'Asthma',
            'Arthritis',
            'Depression',
            'Anxiety',
            'Eating Disorder',
            'Chronic Pain'
          ].map((condition) {
            final isSelected =
                _medicalConditions.any((c) => c.name == condition);
            return FilterChip(
              label: Text(condition),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _medicalConditions.add(MedicalCondition(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: condition,
                      type: 'chronic',
                      severity: 'moderate',
                    ));
                  } else {
                    _medicalConditions.removeWhere((c) => c.name == condition);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Emergency Contact (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addEmergencyContact,
          icon: const Icon(Icons.add),
          label: Text(_emergencyContact == null
              ? 'Add Emergency Contact'
              : 'Edit Emergency Contact'),
        ),
        if (_emergencyContact != null) ...[
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text(_emergencyContact!.name),
              subtitle: Text(
                  '${_emergencyContact!.relationship} - ${_emergencyContact!.phoneNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _addEmergencyContact,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFitnessGoalsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fitness Goals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Lose Weight',
            'Build Muscle',
            'Improve Endurance',
            'Increase Flexibility',
            'Better Sleep',
            'Reduce Stress',
            'Improve Posture',
            'General Fitness'
          ].map((goal) {
            final isSelected = _fitnessGoals.any((g) => g.name == goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _fitnessGoals.add(FitnessGoal(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: goal,
                      category: _getGoalCategory(goal),
                      priority: 3,
                      targetDate: DateTime.now().add(const Duration(days: 90)),
                      isActive: true,
                    ));
                  } else {
                    _fitnessGoals.removeWhere((g) => g.name == goal);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getGoalCategory(String goal) {
    switch (goal) {
      case 'Lose Weight':
      case 'Build Muscle':
        return 'body_composition';
      case 'Improve Endurance':
        return 'cardio';
      case 'Increase Flexibility':
        return 'flexibility';
      case 'Better Sleep':
      case 'Reduce Stress':
        return 'wellness';
      default:
        return 'general';
    }
  }

  Widget _buildWorkoutTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred Workout Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _preferredWorkoutTime,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: ['morning', 'afternoon', 'evening', 'anytime'].map((time) {
            return DropdownMenuItem(
              value: time,
              child: Text(time.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _preferredWorkoutTime = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInterestsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interests (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Yoga',
            'Running',
            'Weightlifting',
            'Swimming',
            'Cycling',
            'Dancing',
            'Martial Arts',
            'Pilates',
            'Hiking',
            'Meditation',
            'Cooking',
            'Reading'
          ].map((interest) {
            return FilterChip(
              label: Text(interest),
              selected: false, // You can implement this with a list
              onSelected: (selected) {
                // Implement interest selection
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Workout Reminders'),
              value: _notificationSettings!.workoutReminders,
              onChanged: (value) {
                setState(() {
                  _notificationSettings =
                      _notificationSettings!.copyWith(workoutReminders: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Meal Reminders'),
              value: _notificationSettings!.mealReminders,
              onChanged: (value) {
                setState(() {
                  _notificationSettings =
                      _notificationSettings!.copyWith(mealReminders: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Mood Check-ins'),
              value: _notificationSettings!.moodCheckIns,
              onChanged: (value) {
                setState(() {
                  _notificationSettings =
                      _notificationSettings!.copyWith(moodCheckIns: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Meditation Reminders'),
              value: _notificationSettings!.meditationReminders,
              onChanged: (value) {
                setState(() {
                  _notificationSettings = _notificationSettings!
                      .copyWith(meditationReminders: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _privacySettings!.profileVisibility,
              decoration:
                  const InputDecoration(labelText: 'Profile Visibility'),
              items: ['public', 'friends', 'private'].map((visibility) {
                return DropdownMenuItem(
                  value: visibility,
                  child: Text(visibility.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _privacySettings =
                      _privacySettings!.copyWith(profileVisibility: value!);
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Activity Sharing'),
              value: _privacySettings!.activitySharing,
              onChanged: (value) {
                setState(() {
                  _privacySettings =
                      _privacySettings!.copyWith(activitySharing: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Data Sharing'),
              value: _privacySettings!.dataSharing,
              onChanged: (value) {
                setState(() {
                  _privacySettings =
                      _privacySettings!.copyWith(dataSharing: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTimezoneFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Localization',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: [
                'en',
                'es',
                'fr',
                'de',
                'it',
                'pt',
                'ru',
                'zh',
                'ja',
                'ko'
              ].map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _timezone,
              decoration: const InputDecoration(labelText: 'Timezone'),
              items: ['UTC', 'EST', 'PST', 'CST', 'MST'].map((tz) {
                return DropdownMenuItem(
                  value: tz,
                  child: Text(tz),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _timezone = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep == 3 ? 'Complete Setup' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _tabController.animateTo(step);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
    } else {
      _completeSetup();
    }
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 25 * 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _dateOfBirth = date;
      });
    }
  }

  Future<void> _selectProfilePicture() async {
    // Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile picture selection not implemented yet')),
    );
  }

  Future<void> _addEmergencyContact() async {
    // Implement emergency contact dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Emergency contact dialog not implemented yet')),
    );
  }

  Future<void> _completeSetup() async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user profile
      final profile = UserProfile(
        id: widget.userId,
        email: widget.email,
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dateOfBirth ?? DateTime(1900),
        gender: _gender ?? Gender.preferNotToSay,
        height: _height,
        weight: _weight,
        activityLevel: _activityLevel ?? ActivityLevel.moderatelyActive,
        fitnessGoals: _fitnessGoals,
        dietaryRestrictions: _dietaryRestrictions,
        medicalConditions: _medicalConditions,
        emergencyContact: _emergencyContact ??
            EmergencyContact(
              name: '',
              relationship: '',
              phoneNumber: '',
            ),
        preferredWorkoutTime: _preferredWorkoutTime,
        timezone: _timezone,
        language: _language,
        notificationSettings: _notificationSettings!,
        privacySettings: _privacySettings!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
      );

      // Save profile using realtime service (replace with your backend if needed)
      final service = ref.read(realtimeProfileServiceProvider);
      await service.updateProfile(profile);
      // mark presence online immediately after setup
      await service.setPresence(widget.userId, true);

      // Navigate to dashboard
      if (mounted) {
        // Navigate to the realtime dashboard which will subscribe to live profile updates
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RealtimeUserDashboard(userId: profile.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty &&
            _dateOfBirth != null;
      case 1:
        return _activityLevel != null;
      case 2:
        return true; // Goals are optional
      case 3:
        return true; // Settings have defaults
      default:
        return true;
    }
  }

  // _saveProfile helper intentionally removed; persistence is done inline via the realtime service.
}

// Extension to add copyWith method to NotificationSettings
extension NotificationSettingsExtension on NotificationSettings {
  NotificationSettings copyWith({
    bool? workoutReminders,
    bool? mealReminders,
    bool? moodCheckIns,
    bool? meditationReminders,
    bool? achievementCelebrations,
    bool? weeklyReports,
    bool? promotionalEmails,
    bool? pushNotifications,
    bool? emailNotifications,
    String? reminderTime,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      workoutReminders: workoutReminders ?? this.workoutReminders,
      mealReminders: mealReminders ?? this.mealReminders,
      moodCheckIns: moodCheckIns ?? this.moodCheckIns,
      meditationReminders: meditationReminders ?? this.meditationReminders,
      achievementCelebrations:
          achievementCelebrations ?? this.achievementCelebrations,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      promotionalEmails: promotionalEmails ?? this.promotionalEmails,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

// Extension to add copyWith method to PrivacySettings
extension PrivacySettingsExtension on PrivacySettings {
  PrivacySettings copyWith({
    String? profileVisibility,
    bool? activitySharing,
    bool? dataSharing,
    bool? locationSharing,
    bool? healthDataSharing,
    List<String>? allowedConnections,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      activitySharing: activitySharing ?? this.activitySharing,
      dataSharing: dataSharing ?? this.dataSharing,
      locationSharing: locationSharing ?? this.locationSharing,
      healthDataSharing: healthDataSharing ?? this.healthDataSharing,
      allowedConnections: allowedConnections ?? this.allowedConnections,
    );
  }
}


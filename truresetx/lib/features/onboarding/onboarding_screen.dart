import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/services/auth_repository.dart';
import '../../core/services/profile_service.dart';
import '../../data/models/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  // auth fields
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // profile fields
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  String _gender = 'preferNotToSay';
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() => _goTo(_index + 1);
  void _back() => _goTo(_index - 1);

  void _goTo(int i) {
    if (i < 0 || i > 3) return;
    setState(() => _index = i);
    _controller.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _performSignUp() async {
    setState(() => _loading = true);
    final repo = ref.read(authRepositoryProvider);
    final profileSvc = ref.read(profileServiceProvider);
    try {
      await repo.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        fullName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      );

      final userId = repo.currentUserId;
      if (userId != null) {
        final profile = UserProfile(
          id: userId,
          email: _emailCtrl.text.trim(),
          fullName: _nameCtrl.text.trim(),
          dateOfBirth: _dob ?? DateTime(1900),
          gender: Gender.preferNotToSay,
          height: 170,
          weight: 70,
          activityLevel: ActivityLevel.moderatelyActive,
          fitnessGoals: const [],
          dietaryRestrictions: const [],
          medicalConditions: const [],
          emergencyContact:
              EmergencyContact(name: '', relationship: '', phoneNumber: ''),
          preferredWorkoutTime: 'morning',
          timezone: 'UTC',
          language: 'en',
          notificationSettings: NotificationSettings(
            workoutReminders: true,
            mealReminders: true,
            moodCheckIns: true,
            meditationReminders: true,
            achievementCelebrations: true,
            weeklyReports: true,
            promotionalEmails: false,
            pushNotifications: true,
            emailNotifications: true,
          ),
          privacySettings: PrivacySettings(
            profileVisibility: 'private',
            activitySharing: false,
            dataSharing: false,
            locationSharing: false,
            healthDataSharing: false,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await profileSvc.createProfile(profile);
        } catch (e) {
          // ignore non-fatal profile create failures
          // ignore: avoid_print
          print('Profile create failed: $e');
        }
      }

      _next();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _performSignIn() async {
    setState(() => _loading = true);
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.signIn(
          email: _emailCtrl.text.trim(), password: _passwordCtrl.text.trim());
      _next();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageText = _dob == null ? 'Unknown' : '${_calculateAge(_dob!)}';

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              SvgPicture.asset('assets/icons/logo.svg', width: 36, height: 36),
        ),
        title: const Text('TruResetX — Onboarding'),
      ),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _welcomeStep(),
          _authStep(),
          _profileStep(ageText),
          _finishStep(),
        ],
      ),
    );
  }

  Widget _stepHeader(IconData icon, String title) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
        ],
      );

  Widget _welcomeStep() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _stepHeader(Icons.waving_hand, 'Welcome to TruResetX'),
            const Text(
              'A privacy-first personal wellness coach. Track mood, sleep, workouts, and receive AI-powered recommendations.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Get started'),
              onPressed: _next,
            ),
          ]),
        ),
      );

  Widget _authStep() => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepHeader(Icons.person, 'Create account or sign in'),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                if (_loading) const CircularProgressIndicator(),
                if (!_loading)
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Sign up'),
                        onPressed: _performSignUp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in'),
                        onPressed: _performSignIn,
                      ),
                    ),
                  ]),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  onPressed: _back,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _profileStep(String ageText) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepHeader(Icons.badge, 'Tell us about you'),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: Text(
                          'Date of birth: ${_dob == null ? 'Not set' : _dob!.toShortDateString()}')),
                  TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick DOB'),
                      onPressed: _pickDob)
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.cake),
                  const SizedBox(width: 8),
                  Text('Age: $ageText')
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  items: const [
                    DropdownMenuItem(
                        value: 'preferNotToSay',
                        child: Text('Prefer not to say')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) =>
                      setState(() => _gender = v ?? 'preferNotToSay'),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Continue'),
                    onPressed: _next),
                const SizedBox(height: 8),
                TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    onPressed: _back),
              ],
            ),
          ),
        ),
      );

  Widget _finishStep() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _stepHeader(Icons.rocket_launch, 'All set!'),
            const Text('You are ready to begin your wellness journey.'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Go to app'),
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
            ),
          ]),
        ),
      );

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}

extension on DateTime {
  String toShortDateString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

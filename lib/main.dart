// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/firebase/firebase_config.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/setup_goals_screen.dart';
import 'screens/spiritual/belief_setup_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/mind/mind_screen.dart';
import 'screens/spirit/spirit_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/profile/theme_settings_screen.dart';
import 'screens/profile/notifications_settings_screen.dart';
import 'screens/profile/privacy_settings_screen.dart';
import 'screens/profile/connected_devices_screen.dart';
import 'screens/not_found_screen.dart';
import 'widgets/auth_gate.dart';
import 'screens/mood/quick_log_screen.dart';
import 'screens/mind/cbt_journal_screen.dart';
import 'screens/spiritual/daily_practice_screen.dart';
import 'screens/workout/workout_list_screen.dart';
import 'screens/workout/workout_player_screen.dart';
import 'screens/nutrition/water_tracker_screen.dart';
import 'screens/analytics/weekly_progress_screen.dart';
import 'screens/mood/mood_timeline_screen.dart';
import 'screens/nutrition/nutrition_log_screen.dart';
import 'screens/nutrition/ai_meal_planner_screen.dart';
import 'screens/analytics/achievements_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/permissions_setup_screen.dart';
import 'screens/spiritual/mantras_library_screen.dart';
import 'screens/spiritual/audio_verse_player_screen.dart';
import 'screens/spiritual/rituals_tracker_screen.dart';
import 'screens/spiritual/calendar_view_screen.dart';
import 'screens/spiritual/wisdom_feed_screen.dart';
import 'screens/wisdom/daily_wisdom_screen.dart';
import 'screens/wisdom/wisdom_library_screen.dart';
import 'screens/wisdom/wisdom_legends_screen.dart';
import 'screens/wisdom/wisdom_detail_screen.dart';
import 'screens/wisdom/wisdom_tracker_screen.dart';
import 'screens/spiritual/streaks_detail_screen.dart';
import 'screens/spiritual/yoga_routine_screen.dart';
import 'screens/mood/mood_correlation_screen.dart';
import 'screens/mind/mood_coach_screen.dart';
import 'screens/mind/guided_sessions_screen.dart';
import 'screens/mind/sos_mode_screen.dart';
import 'screens/mind/assessments_screen.dart';
import 'screens/mind/results_screen.dart';
import 'screens/mind/coach_inbox_screen.dart';
import 'screens/workout/exercise_detail_screen.dart';
import 'screens/workout/ar_assist_screen.dart';
import 'screens/workout/workout_generator_wizard_screen.dart';
import 'screens/nutrition/grocery_list_screen.dart';
import 'screens/nutrition/fasting_mode_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load local environment variables (e.g. OPENAI_API_KEY)
  // On some platforms (web) the .env file may not be available as an asset.
  // Don't fail app startup if dotenv cannot find the file — log and continue.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // ignore: avoid_print
    debugPrint('dotenv load failed: $e');
  }

  await FirebaseConfig.initialize();
  runApp(
    const ProviderScope(
      child: TruResetXApp(),
    ),
  );
}

class TruResetXApp extends StatelessWidget {
  const TruResetXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TruResetX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => SignInScreen(
        redirect: Uri.base.queryParameters['redirect'],
      ),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) => const OTPVerificationScreen(),
    ),
    GoRoute(
      path: '/permissions-setup',
      builder: (context, state) => const PermissionsSetupScreen(),
    ),
    GoRoute(
      path: '/setup-goals',
      builder: (context, state) => const SetupGoalsScreen(),
    ),
    GoRoute(
      path: '/belief-setup',
      builder: (context, state) => const BeliefSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const AuthGate(child: DashboardScreen()),
      routes: [
        GoRoute(
          path: 'workouts',
          builder: (context, state) => const WorkoutListScreen(),
          routes: [
            GoRoute(
              path: 'generator',
              builder: (context, state) => const WorkoutGeneratorWizardScreen(),
            ),
            GoRoute(
              path: 'player',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return WorkoutPlayerScreen(
                  exercises: extra?['exercises'] as List<Map<String, dynamic>>?,
                  workoutName: extra?['name'] as String?,
                );
              },
            ),
            GoRoute(
              path: 'exercise/:id',
              builder: (context, state) => const ExerciseDetailScreen(),
            ),
            GoRoute(
              path: 'ar-assist',
              builder: (context, state) => const ARAssistScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'water-tracker',
          builder: (context, state) => const WaterTrackerScreen(),
        ),
        GoRoute(
          path: 'weekly-progress',
          builder: (context, state) => const WeeklyProgressScreen(),
        ),
        GoRoute(
          path: 'chatbot',
          builder: (context, state) => const ChatbotScreen(),
        ),
        GoRoute(
          path: 'nutrition-log',
          builder: (context, state) => const NutritionLogScreen(),
        ),
        GoRoute(
          path: 'meal-planner',
          builder: (context, state) => const AIMealPlannerScreen(),
        ),
        GoRoute(
          path: 'grocery-list',
          builder: (context, state) => const GroceryListScreen(),
        ),
        GoRoute(
          path: 'fasting-mode',
          builder: (context, state) => const FastingModeScreen(),
        ),
        GoRoute(
          path: 'achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/mind',
      builder: (context, state) => const AuthGate(child: MindScreen()),
      routes: [
        GoRoute(
          path: 'mood-log',
          builder: (context, state) => const QuickLogScreen(),
        ),
        GoRoute(
          path: 'cbt-journal',
          builder: (context, state) => const CBTJournalScreen(),
        ),
        GoRoute(
          path: 'mood-timeline',
          builder: (context, state) => const MoodTimelineScreen(),
        ),
        GoRoute(
          path: 'mood-correlation',
          builder: (context, state) => const MoodCorrelationScreen(),
        ),
        GoRoute(
          path: 'mood-coach',
          builder: (context, state) => const MoodCoachScreen(),
        ),
        GoRoute(
          path: 'guided-sessions',
          builder: (context, state) => const GuidedSessionsScreen(),
        ),
        GoRoute(
          path: 'sos-mode',
          builder: (context, state) => const SOSModeScreen(),
        ),
        GoRoute(
          path: 'assessments',
          builder: (context, state) => const AssessmentsScreen(),
        ),
        GoRoute(
          path: 'results',
          builder: (context, state) => const ResultsScreen(),
        ),
        GoRoute(
          path: 'coach-inbox',
          builder: (context, state) => const CoachInboxScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/spirit',
      builder: (context, state) => const AuthGate(child: SpiritScreen()),
      routes: [
        GoRoute(
          path: 'daily-practice',
          builder: (context, state) => const DailyPracticeScreen(),
        ),
        // Wisdom section routes
        GoRoute(
          path: 'wisdom-daily',
          builder: (context, state) => const DailyWisdomScreen(),
        ),
        GoRoute(
          path: 'wisdom-library',
          builder: (context, state) => const WisdomLibraryScreen(),
        ),
        GoRoute(
          path: 'wisdom-legends',
          builder: (context, state) => const WisdomLegendsScreen(),
        ),
        GoRoute(
          path: 'wisdom/:id',
          builder: (context, state) {
            // Some go_router versions expose params differently; to be
            // resilient we parse the id from the URI path segments.
            final segments = state.uri.pathSegments;
            final id = segments.isNotEmpty ? segments.last : '';
            return WisdomDetailScreen(wisdomId: id);
          },
        ),
        GoRoute(
          path: 'wisdom-tracker',
          builder: (context, state) => const WisdomTrackerScreen(),
        ),
        GoRoute(
          path: 'mantras',
          builder: (context, state) => const MantrasLibraryScreen(),
        ),
        GoRoute(
          path: 'audio-player',
          builder: (context, state) => const AudioVersePlayerScreen(),
        ),
        GoRoute(
          path: 'rituals',
          builder: (context, state) => const RitualsTrackerScreen(),
        ),
        GoRoute(
          path: 'calendar',
          builder: (context, state) => const CalendarViewScreen(),
        ),
        GoRoute(
          path: 'wisdom-feed',
          builder: (context, state) => const WisdomFeedScreen(),
        ),
        GoRoute(
          path: 'streaks',
          builder: (context, state) => const StreaksDetailScreen(),
        ),
        GoRoute(
          path: 'yoga',
          builder: (context, state) => const YogaRoutineScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const AuthGate(child: ProfileScreen()),
      routes: [
        GoRoute(
          path: 'theme',
          builder: (context, state) => const ThemeSettingsScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationsSettingsScreen(),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) => const PrivacySettingsScreen(),
        ),
        GoRoute(
          path: 'devices',
          builder: (context, state) => const ConnectedDevicesScreen(),
        ),
      ],
    ),
  ],
);

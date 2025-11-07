// Environment configuration for TruResetX v1.0
//
// NOTE: Keep secrets out of source control. Use --dart-define or platform
// environment variables to provide values for CI and local development.
import 'env_runtime.dart';

class Environment {
  // Compile-time defines take precedence. If they aren't set, fall back to
  // values loaded at runtime from a `.env` file via `EnvRuntime`.
  static String get supabaseUrl {
    const v = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (v.isNotEmpty) return v;
    try {
      // Use runtime loader when available (development)
      final r = EnvRuntime.get('SUPABASE_URL');
      return r ?? 'https://your-project.supabase.co';
    } catch (_) {
      return 'https://your-project.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    const v = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (v.isNotEmpty) return v;
    try {
      return EnvRuntime.get('SUPABASE_ANON_KEY') ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get openaiApiKey {
    const v = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (v.isNotEmpty) return v;
    try {
      return EnvRuntime.get('OPENAI_API_KEY') ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get firebaseProjectId {
    const v = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
    if (v.isNotEmpty) return v;
    try {
      return EnvRuntime.get('FIREBASE_PROJECT_ID') ?? 'truresetx-lite';
    } catch (_) {
      return 'truresetx-lite';
    }
  }

  // App configuration
  static const String appName = 'TruResetX';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature flags
  static const bool enableARWorkouts = true;
  static const bool enableFoodScan = true;
  static const bool enableAICoach = true;
  static const bool enableSpiritualFeatures = true;
  static const bool enableCommunityFeatures = false; // Coming in v1.5

  // AI Coach personas
  static const List<String> aiPersonas = ['astra', 'sage', 'fuel'];

  // Default values
  static const int defaultWorkoutDuration = 30; // minutes
  static const int defaultMeditationDuration = 10; // minutes
  static const int maxChatHistoryDays = 30;
  static const int maxNotificationRetries = 3;

  // AR Configuration
  static const double minPoseConfidence = 0.7;
  static const double minFormScore = 0.6;
  static const int maxRepsPerSet = 50;

  // Nutrition Configuration
  static const double minFoodConfidence = 0.8;
  static const int maxCaloriesPerMeal = 2000;
  static const int maxMacroGrams = 500;

  // Mood Configuration
  static const int moodScaleMin = 1;
  static const int moodScaleMax = 10;
  static const int maxMoodLogsPerDay = 10;

  // Streak Configuration
  static const int maxStreakDays = 365;
  static const int streakResetDays = 7; // Reset if inactive for 7 days

  // Notification Configuration
  static const int morningReminderHour = 8;
  static const int eveningReflectionHour = 20;
  static const int workoutReminderMinutes = 30; // Before scheduled workout

  // Storage Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];

  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const int analyticsBatchSize = 10;

  // Development flags
  static const bool isDevelopment =
      bool.fromEnvironment('dart.vm.product') == false;
  static const bool enableDebugLogs = isDevelopment;
  static const bool enablePerformanceMonitoring = true;

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Cache Configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiration = Duration(hours: 24);

  // Security Configuration
  static const bool enableBiometricAuth = true;
  static const bool enableDataEncryption = true;
  static const Duration sessionTimeout = Duration(hours: 24);

  // Clerk (optional) backend URL for server-mediated Clerk flows
  // e.g. provide via --dart-define=CLERK_BASE_URL
  static String get clerkBaseUrl {
    const v = String.fromEnvironment('CLERK_BASE_URL', defaultValue: '');
    if (v.isNotEmpty) return v;
    try {
      return EnvRuntime.get('CLERK_BASE_URL') ?? '';
    } catch (_) {
      return '';
    }
  }

  // Validation
  static bool get isConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
      supabaseAnonKey.isNotEmpty &&
      openaiApiKey.isNotEmpty;

  static void validateConfiguration() {
    if (!isConfigured) {
      throw Exception(
          'Environment configuration is incomplete. Please set required environment variables: SUPABASE_URL, SUPABASE_ANON_KEY, OPENAI_API_KEY (use --dart-define or platform env).');
    }
  }

  // Get environment-specific configuration
  static Map<String, dynamic> getConfig() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'supabaseUrl': supabaseUrl,
      'features': {
        'arWorkouts': enableARWorkouts,
        'foodScan': enableFoodScan,
        'aiCoach': enableAICoach,
        'spiritual': enableSpiritualFeatures,
        'community': enableCommunityFeatures,
      },
      'ai': {
        'personas': aiPersonas,
        'maxChatHistoryDays': maxChatHistoryDays,
      },
      'ar': {
        'minPoseConfidence': minPoseConfidence,
        'minFormScore': minFormScore,
        'maxRepsPerSet': maxRepsPerSet,
      },
      'nutrition': {
        'minFoodConfidence': minFoodConfidence,
        'maxCaloriesPerMeal': maxCaloriesPerMeal,
        'maxMacroGrams': maxMacroGrams,
      },
      'mood': {
        'scaleMin': moodScaleMin,
        'scaleMax': moodScaleMax,
        'maxLogsPerDay': maxMoodLogsPerDay,
      },
      'notifications': {
        'morningHour': morningReminderHour,
        'eveningHour': eveningReflectionHour,
        'workoutReminderMinutes': workoutReminderMinutes,
      },
      'development': {
        'isDevelopment': isDevelopment,
        'enableDebugLogs': enableDebugLogs,
        'enablePerformanceMonitoring': enablePerformanceMonitoring,
      },
    };
  }
}

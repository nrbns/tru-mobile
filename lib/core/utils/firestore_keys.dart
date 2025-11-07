/// Centralized Firestore collection/key names used across the app.
/// Keep all collection and subcollection names here so they can be
/// changed in one place when database structure evolves.
class FirestoreKeys {
  // Top-level collections
  static const String users = 'users';
  static const String affirmations = 'affirmations';
  static const String soundHealing = 'sound_healing';
  static const String mantras = 'mantras';
  static const String wisdomPosts = 'wisdom_posts';
  static const String sacredVerses = 'sacred_verses';
  static const String scriptures = 'scriptures';
  static const String devotionals = 'devotionals';
  static const String prayerTimes = 'prayer_times';
  static const String lessons = 'lessons';
  static const String yogaSessions = 'yoga_sessions';
  static const String yogaPoses = 'yoga_poses';
  static const String gratitudeJournals = 'gratitude_journals';
  static const String karmaLogs = 'karma_logs';
  static const String affirmationSessions = 'affirmation_sessions';
  static const String guidedVisualizations = 'guided_visualizations';
  static const String guidedYoga = 'guided_yoga';

  // Additional spiritual & media collections
  static const String spiritualStories = 'spiritual_stories';
  static const String storyReflections = 'story_reflections';
  static const String videoLibrary = 'video_library';
  static const String videoWatches = 'video_watches';
  static const String practices = 'practices';
  static const String practiceLogs = 'practice_logs';
  static const String dailyCards = 'daily_cards';

  // User subcollections (for convenience)
  static const String userTraditions = 'traditions';

  // Common document fields
  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';
  static const String fieldDate = 'date';
}

import * as admin from "firebase-admin";

// Initialize only if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Comprehensive Seed Data Script for ALL TruResetX Features
 * Populates: Exercises, Challenges, Badges, Meditations, Ambient Sounds, Calendar Events
 */
export async function seedAllFeaturesData() {
  console.log("🌱 Seeding all TruResetX features with real data...");

  // 1. SEED EXERCISES LIBRARY (100+ real exercises)
  await seedExercises();
  
  // 2. SEED CHALLENGES
  await seedChallenges();
  
  // 3. SEED BADGES/ACHIEVEMENTS
  await seedBadges();
  
  // 4. SEED MEDITATIONS
  await seedMeditations();
  
  // 5. SEED AMBIENT SOUNDS
  await seedAmbientSounds();
  
  // 6. SEED CALENDAR EVENTS (if not already populated)
  await seedCalendarEvents();

  console.log("✨ All features data seeding complete!");
}

// ============================================
// 1. EXERCISES LIBRARY
// ============================================
async function seedExercises() {
  console.log("🏋️ Seeding exercises library...");

  const exercises = [
    // Upper Body - Chest
    {
      name: "Push-ups",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Start in plank position, lower body until chest nearly touches floor, push back up. Keep core tight and don't let hips sag.",
      tips: ["Keep core tight", "Full range of motion", "Don't let hips sag", "Control the movement"],
    },
    {
      name: "Diamond Push-ups",
      muscle_groups: ["chest", "triceps"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Form diamond shape with hands, keep elbows close to body while lowering and pushing up.",
      tips: ["Targets triceps more", "Keep elbows in", "Full range of motion"],
    },
    {
      name: "Incline Push-ups",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Place hands on elevated surface, perform push-ups at an angle. Easier variation.",
      tips: ["Great for beginners", "Adjust height for difficulty"],
    },
    {
      name: "Dumbbell Bench Press",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["dumbbells", "bench"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Lie on bench, press dumbbells from chest level until arms fully extended. Lower with control.",
      tips: ["Control the weight", "Full range of motion", "Keep feet planted", "Don't bounce at bottom"],
    },
    {
      name: "Barbell Bench Press",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["barbell", "bench"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Lower bar to chest, press up until arms locked. Use spotter for heavy weights.",
      tips: ["Control the descent", "Full lockout", "Keep shoulder blades retracted"],
    },
    {
      name: "Chest Flyes",
      muscle_groups: ["chest"],
      equipment: ["dumbbells", "bench"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Lie on bench, arms extended, lower dumbbells in arc motion, bring back together.",
      tips: ["Slight bend in elbows", "Feel chest stretch", "Control the movement"],
    },

    // Upper Body - Back
    {
      name: "Pull-ups",
      muscle_groups: ["back", "biceps"],
      equipment: ["pull-up bar"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Hang from bar, pull body up until chin clears bar. Lower with control.",
      tips: ["Full range of motion", "Control the descent", "Engage lats", "Keep core tight"],
    },
    {
      name: "Chin-ups",
      muscle_groups: ["back", "biceps"],
      equipment: ["pull-up bar"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Hang with palms facing you, pull up until chin over bar.",
      tips: ["Targets biceps more", "Easier than pull-ups", "Full range"],
    },
    {
      name: "Inverted Rows",
      muscle_groups: ["back", "biceps"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Under bar, pull body up until chest touches bar. Adjust angle for difficulty.",
      tips: ["Great for beginners", "Increase angle for difficulty", "Keep body straight"],
    },
    {
      name: "Dumbbell Rows",
      muscle_groups: ["back", "biceps"],
      equipment: ["dumbbells"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Bend over, pull dumbbell to hip, squeeze back muscles at top. Alternate sides.",
      tips: ["Keep core tight", "Don't swing", "Elbow close to body", "Feel lats working"],
    },
    {
      name: "Barbell Rows",
      muscle_groups: ["back", "biceps"],
      equipment: ["barbell"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Bend at hips, pull bar to lower chest/upper abs, squeeze lats at top.",
      tips: ["Back straight", "Elbows close", "Full range", "Control weight"],
    },
    {
      name: "Lat Pulldowns",
      muscle_groups: ["back", "biceps"],
      equipment: ["cable", "machine"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Pull bar down to upper chest, squeeze lats, control the return.",
      tips: ["Lean back slightly", "Full range", "Feel in back not arms"],
    },

    // Upper Body - Shoulders
    {
      name: "Dumbbell Shoulder Press",
      muscle_groups: ["shoulders", "triceps"],
      equipment: ["dumbbells"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Press dumbbells overhead until arms fully extended. Lower with control.",
      tips: ["Core engaged", "Don't arch back excessively", "Control descent", "Full lockout"],
    },
    {
      name: "Lateral Raises",
      muscle_groups: ["shoulders"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Raise dumbbells to sides until parallel to floor, lower slowly.",
      tips: ["Slight bend in elbows", "No swinging", "Feel side delts", "Control movement"],
    },
    {
      name: "Front Raises",
      muscle_groups: ["shoulders"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Raise dumbbell forward until parallel to floor, lower with control.",
      tips: ["One arm at a time or both", "Control the movement", "Feel front delts"],
    },
    {
      name: "Rear Delt Flyes",
      muscle_groups: ["shoulders"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Bend over, raise dumbbells to sides, squeeze rear delts.",
      tips: ["Slight bend in elbows", "Focus on rear delts", "Control movement"],
    },

    // Upper Body - Arms
    {
      name: "Dumbbell Bicep Curls",
      muscle_groups: ["biceps"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Curl dumbbells up by flexing biceps, lower slowly with control.",
      tips: ["Don't swing", "Full contraction", "Control negative", "Keep elbows still"],
    },
    {
      name: "Hammer Curls",
      muscle_groups: ["biceps", "forearms"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Curl dumbbells with neutral grip (palms facing each other).",
      tips: ["Targets brachialis", "Works forearms too", "Control movement"],
    },
    {
      name: "Dumbbell Tricep Extension",
      muscle_groups: ["triceps"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Extend arms overhead, lower dumbbell behind head, extend back up.",
      tips: ["Keep elbows stationary", "Full extension", "Control movement", "Feel triceps"],
    },
    {
      name: "Tricep Dips",
      muscle_groups: ["triceps", "shoulders"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Lower body by bending elbows, push back up. Use bench or bars.",
      tips: ["Full range", "Keep torso upright", "Feel triceps", "Modify if needed"],
    },

    // Lower Body - Quads & Glutes
    {
      name: "Bodyweight Squats",
      muscle_groups: ["quadriceps", "glutes"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Lower body by bending knees until thighs parallel to floor, drive up through heels.",
      tips: ["Keep knees aligned", "Back straight", "Depth matters", "Drive through heels"],
    },
    {
      name: "Barbell Squat",
      muscle_groups: ["quadriceps", "glutes", "hamstrings"],
      equipment: ["barbell", "squat rack"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Lower body until thighs parallel or below, drive up through heels, keep core tight.",
      tips: ["Depth is key", "Keep back tight", "Knees out", "Core engaged"],
    },
    {
      name: "Lunges",
      muscle_groups: ["quadriceps", "glutes", "hamstrings"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Step forward, lower back knee toward ground, drive back to start. Alternate legs.",
      tips: ["Front knee over ankle", "Keep torso upright", "Full range", "Control movement"],
    },
    {
      name: "Walking Lunges",
      muscle_groups: ["quadriceps", "glutes", "hamstrings"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Step forward into lunge, push up and through to next lunge, continue walking forward.",
      tips: ["Smooth rhythm", "Maintain balance", "Full range", "Engage core"],
    },
    {
      name: "Bulgarian Split Squats",
      muscle_groups: ["quadriceps", "glutes"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Back foot elevated, lower down on front leg, drive up through front heel.",
      tips: ["Front foot forward", "Feel in front leg", "Keep torso upright", "Deep range"],
    },
    {
      name: "Leg Press",
      muscle_groups: ["quadriceps", "glutes", "hamstrings"],
      equipment: ["machine"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Press platform away until legs extended, lower with control to 90 degrees.",
      tips: ["Full range", "Don't lock knees", "Feel in quads", "Control weight"],
    },

    // Lower Body - Hamstrings
    {
      name: "Romanian Deadlift",
      muscle_groups: ["hamstrings", "glutes", "back"],
      equipment: ["barbell", "dumbbells"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Hinge at hips, lower bar/dumbbells along legs, feel hamstring stretch, drive hips forward.",
      tips: ["Keep back straight", "Feel hamstrings", "Don't round back", "Hinge at hips"],
    },
    {
      name: "Glute Bridges",
      muscle_groups: ["glutes", "hamstrings"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Lie on back, drive hips up by squeezing glutes, lower with control.",
      tips: ["Squeeze glutes", "Full extension", "Control movement", "Feel in glutes"],
    },
    {
      name: "Hip Thrusts",
      muscle_groups: ["glutes", "hamstrings"],
      equipment: ["barbell", "dumbbell"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Shoulders on bench, drive hips up with weight on hips, squeeze glutes at top.",
      tips: ["Max glute activation", "Full extension", "Control movement", "Feel in glutes"],
    },
    {
      name: "Lying Leg Curls",
      muscle_groups: ["hamstrings"],
      equipment: ["machine"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Curl legs up by flexing hamstrings, lower with control.",
      tips: ["Full range", "Control negative", "Feel hamstrings", "Don't swing"],
    },

    // Core
    {
      name: "Plank",
      muscle_groups: ["abs", "core", "shoulders"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Hold body straight in push-up position, supported by forearms. Keep core tight.",
      tips: ["Straight line head to heels", "Engage core", "Breathe normally", "Don't sag"],
    },
    {
      name: "Side Plank",
      muscle_groups: ["abs", "obliques", "core"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Hold body straight on side, supported by one forearm and side of foot.",
      tips: ["Keep body straight", "Engage obliques", "Hold steady", "Breathe"],
    },
    {
      name: "Crunches",
      muscle_groups: ["abs"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Curl upper body toward knees, squeeze abs, lower with control.",
      tips: ["Don't pull on neck", "Feel in abs", "Full range", "Control movement"],
    },
    {
      name: "Russian Twists",
      muscle_groups: ["abs", "obliques"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Sit with knees bent, lean back, rotate torso side to side.",
      tips: ["Keep core engaged", "Control rotation", "Feel obliques", "Add weight for difficulty"],
    },
    {
      name: "Mountain Climbers",
      muscle_groups: ["core", "shoulders", "cardio"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Alternate bringing knees to chest in plank position at fast pace.",
      tips: ["Keep core tight", "Smooth rhythm", "Full range", "Cardio component"],
    },
    {
      name: "Dead Bug",
      muscle_groups: ["core"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: false,
      instructions: "Lie on back, extend opposite arm and leg, return, alternate sides.",
      tips: ["Keep lower back on floor", "Control movement", "Feel core", "Slow and controlled"],
    },

    // Cardio/Full Body
    {
      name: "Burpees",
      muscle_groups: ["full body", "cardio"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Squat, jump back to plank, push-up, jump forward, jump up with arms overhead.",
      tips: ["Full extension on jump", "Stay controlled", "Modify if needed", "High intensity"],
    },
    {
      name: "Jumping Jacks",
      muscle_groups: ["cardio", "full body"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Jump up while spreading legs and raising arms, return to start.",
      tips: ["Good warm-up", "Steady pace", "Full range", "Cardio focus"],
    },
    {
      name: "High Knees",
      muscle_groups: ["cardio", "core"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      instructions: "Run in place, bringing knees up high toward chest, pump arms.",
      tips: ["Fast pace", "High knee lift", "Engage core", "Cardio intensity"],
    },
    {
      name: "Jump Squats",
      muscle_groups: ["quadriceps", "glutes", "cardio"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Perform squat, explosively jump up, land softly and immediately go into next squat.",
      tips: ["Explosive movement", "Soft landing", "Full range", "Plyometric"],
    },

    // Additional Full Body
    {
      name: "Kettlebell Swings",
      muscle_groups: ["glutes", "hamstrings", "core", "shoulders"],
      equipment: ["kettlebell"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Hinge at hips, swing kettlebell from between legs to chest height using hip drive.",
      tips: ["Hip drive not arms", "Keep back straight", "Feel glutes", "Control at top"],
    },
    {
      name: "Battle Ropes",
      muscle_groups: ["shoulders", "core", "cardio"],
      equipment: ["battle ropes"],
      difficulty: "intermediate",
      is_compound: true,
      instructions: "Alternate whipping ropes up and down in waves, keep core tight.",
      tips: ["High intensity", "Full body", "Cardio component", "Control the waves"],
    },
  ];

  const batch = db.batch();
  const exercisesRef = db.collection("exercises");

  exercises.forEach((exercise) => {
    const docRef = exercisesRef.doc();
    batch.set(docRef, {
      ...exercise,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`✅ Seeded ${exercises.length} exercises`);
}

// ============================================
// 2. CHALLENGES
// ============================================
async function seedChallenges() {
  console.log("🎯 Seeding challenges...");

  const challenges = [
    // Body Challenges
    {
      title: "7-Day Workout Starter",
      description: "Complete at least 15 minutes of exercise every day for 7 days. Perfect for building a consistent workout habit.",
      category: "body",
      difficulty: "beginner",
      duration_days: 7,
      metrics: { workouts_completed: 7 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "30-Day Fitness Challenge",
      description: "Commit to 30 days of regular workouts. Mix strength, cardio, and flexibility. Transform your fitness in one month.",
      category: "body",
      difficulty: "intermediate",
      duration_days: 30,
      metrics: { workouts_completed: 30 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "10,000 Steps Daily",
      description: "Walk 10,000 steps every day for 14 days. Boost your daily activity and improve cardiovascular health.",
      category: "body",
      difficulty: "beginner",
      duration_days: 14,
      metrics: { daily_steps: 10000 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Strength Builder",
      description: "Complete 20 strength training sessions in 6 weeks. Focus on progressive overload and proper form.",
      category: "body",
      difficulty: "intermediate",
      duration_days: 42,
      metrics: { strength_sessions: 20 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },

    // Mind Challenges
    {
      title: "Daily Meditation",
      description: "Meditate for at least 10 minutes every day for 21 days. Build mindfulness and reduce stress.",
      category: "mind",
      difficulty: "beginner",
      duration_days: 21,
      metrics: { meditation_days: 21 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Mood Tracker",
      description: "Log your mood every day for 30 days. Understand your emotional patterns and triggers.",
      category: "mind",
      difficulty: "beginner",
      duration_days: 30,
      metrics: { mood_logs: 30 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Gratitude Practice",
      description: "Write three things you're grateful for each morning for 14 days. Cultivate positivity and mindfulness.",
      category: "mind",
      difficulty: "beginner",
      duration_days: 14,
      metrics: { gratitude_entries: 14 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Sleep Quality",
      description: "Track your sleep and aim for 7-9 hours for 21 days. Improve rest and recovery.",
      category: "mind",
      difficulty: "beginner",
      duration_days: 21,
      metrics: { sleep_hours: 7 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },

    // Spirit Challenges
    {
      title: "Daily Practice",
      description: "Complete your spiritual practice (meditation, prayer, reflection) every day for 30 days.",
      category: "spirit",
      difficulty: "beginner",
      duration_days: 30,
      metrics: { practice_days: 30 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Mantra Mastery",
      description: "Practice mantras or affirmations daily for 21 days. Deepen your spiritual connection.",
      category: "spirit",
      difficulty: "beginner",
      duration_days: 21,
      metrics: { mantra_sessions: 21 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Wisdom Seeker",
      description: "Read and reflect on spiritual wisdom daily for 14 days. Expand your understanding.",
      category: "spirit",
      difficulty: "beginner",
      duration_days: 14,
      metrics: { wisdom_readings: 14 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },

    // Combined Challenges
    {
      title: "Holistic Wellness",
      description: "Complete all three: workout, meditation, and spiritual practice every day for 7 days. Full body-mind-spirit integration.",
      category: "combined",
      difficulty: "intermediate",
      duration_days: 7,
      metrics: { workouts: 7, meditations: 7, practices: 7 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: "Perfect Week",
      description: "Log mood, workout, nutrition, and spiritual practice every day for 7 days. Complete wellness tracking.",
      category: "combined",
      difficulty: "intermediate",
      duration_days: 7,
      metrics: { mood_logs: 7, workouts: 7, meals: 21, practices: 7 },
      active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    },
  ];

  const batch = db.batch();
  const challengesRef = db.collection("challenges");

  challenges.forEach((challenge) => {
    const docRef = challengesRef.doc();
    batch.set(docRef, challenge);
  });

  await batch.commit();
  console.log(`✅ Seeded ${challenges.length} challenges`);
}

// ============================================
// 3. BADGES/ACHIEVEMENTS
// ============================================
async function seedBadges() {
  console.log("🏆 Seeding badges...");

  const badges = [
    // Milestone Badges
    {
      id: "streak_7",
      name: "Week Warrior",
      description: "Maintain a 7-day streak",
      category: "milestone",
      icon: "🔥",
      rarity: "common",
    },
    {
      id: "streak_30",
      name: "Month Master",
      description: "Maintain a 30-day streak",
      category: "milestone",
      icon: "⭐",
      rarity: "rare",
    },
    {
      id: "streak_100",
      name: "Century Champion",
      description: "Maintain a 100-day streak",
      category: "milestone",
      icon: "💎",
      rarity: "epic",
    },

    // Body Badges
    {
      id: "workout_10",
      name: "Getting Started",
      description: "Complete 10 workouts",
      category: "body",
      icon: "💪",
      rarity: "common",
    },
    {
      id: "workout_50",
      name: "Fitness Enthusiast",
      description: "Complete 50 workouts",
      category: "body",
      icon: "🏋️",
      rarity: "rare",
    },
    {
      id: "workout_100",
      name: "Workout Warrior",
      description: "Complete 100 workouts",
      category: "body",
      icon: "👑",
      rarity: "epic",
    },
    {
      id: "strength_builder",
      name: "Strength Builder",
      description: "Complete 20 strength training sessions",
      category: "body",
      icon: "🏋️‍♂️",
      rarity: "rare",
    },
    {
      id: "cardio_king",
      name: "Cardio King",
      description: "Complete 30 cardio sessions",
      category: "body",
      icon: "❤️",
      rarity: "rare",
    },

    // Mind Badges
    {
      id: "mood_tracker_30",
      name: "Self-Aware",
      description: "Log mood 30 times",
      category: "mind",
      icon: "🧠",
      rarity: "common",
    },
    {
      id: "mood_tracker_100",
      name: "Emotional Intelligence",
      description: "Log mood 100 times",
      category: "mind",
      icon: "🎭",
      rarity: "rare",
    },
    {
      id: "meditation_completed",
      name: "Mindful Moment",
      description: "Complete a meditation session",
      category: "mind",
      icon: "🧘",
      rarity: "common",
    },
    {
      id: "meditation_streak_7",
      name: "Zen Beginner",
      description: "Meditate 7 days in a row",
      category: "mind",
      icon: "🌿",
      rarity: "common",
    },
    {
      id: "meditation_streak_30",
      name: "Zen Master",
      description: "Meditate 30 days in a row",
      category: "mind",
      icon: "🕉️",
      rarity: "rare",
    },
    {
      id: "cbt_explorer",
      name: "CBT Explorer",
      description: "Complete 10 CBT journal entries",
      category: "mind",
      icon: "📝",
      rarity: "common",
    },

    // Spirit Badges
    {
      id: "spiritual_streak_7",
      name: "Sadhana Starter",
      description: "Complete 7 days of spiritual practice",
      category: "spirit",
      icon: "🙏",
      rarity: "common",
    },
    {
      id: "spiritual_streak_30",
      name: "Devoted Practitioner",
      description: "Complete 30 days of spiritual practice",
      category: "spirit",
      icon: "🌟",
      rarity: "rare",
    },
    {
      id: "wisdom_reflector",
      name: "Wisdom Reflector",
      description: "Complete 10 wisdom reflections",
      category: "spirit",
      icon: "📖",
      rarity: "common",
    },
    {
      id: "mantra_master",
      name: "Mantra Master",
      description: "Practice mantras 21 days",
      category: "spirit",
      icon: "🕉️",
      rarity: "rare",
    },
    {
      id: "gratitude_champion",
      name: "Gratitude Champion",
      description: "Write gratitude entries for 30 days",
      category: "spirit",
      icon: "💝",
      rarity: "rare",
    },

    // Challenge Badges
    {
      id: "challenge_completer",
      name: "Challenge Completer",
      description: "Complete your first challenge",
      category: "milestone",
      icon: "🎯",
      rarity: "common",
    },
    {
      id: "challenge_master",
      name: "Challenge Master",
      description: "Complete 10 challenges",
      category: "milestone",
      icon: "🏆",
      rarity: "rare",
    },

    // Daily Badges
    {
      id: "daily_meditation",
      name: "Daily Meditator",
      description: "Complete meditation today",
      category: "mind",
      icon: "☀️",
      rarity: "common",
    },
    {
      id: "daily_workout",
      name: "Daily Exerciser",
      description: "Complete workout today",
      category: "body",
      icon: "⚡",
      rarity: "common",
    },
    {
      id: "daily_practice",
      name: "Daily Practice",
      description: "Complete spiritual practice today",
      category: "spirit",
      icon: "✨",
      rarity: "common",
    },
  ];

  const batch = db.batch();
  const badgesRef = db.collection("badges");

  badges.forEach((badge) => {
    const docRef = badgesRef.doc(badge.id);
    batch.set(docRef, {
      ...badge,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`✅ Seeded ${badges.length} badges`);
}

// ============================================
// 4. MEDITATIONS
// ============================================
async function seedMeditations() {
  console.log("🧘 Seeding meditations...");

  const meditations = [
    {
      title: "5-Minute Morning Mindfulness",
      description: "Start your day with clarity and intention. A brief guided meditation to set a positive tone.",
      category: "focus",
      difficulty: "beginner",
      duration: 5,
      tags: ["morning", "focus", "intention"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "10-Minute Stress Relief",
      description: "Release tension and find calm. Perfect for mid-day reset or after a stressful moment.",
      category: "stress",
      difficulty: "beginner",
      duration: 10,
      tags: ["stress", "relaxation", "calm"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "15-Minute Body Scan",
      description: "Progressive relaxation through your entire body. Deep rest and awareness practice.",
      category: "relaxation",
      difficulty: "beginner",
      duration: 15,
      tags: ["body scan", "relaxation", "awareness"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "20-Minute Sleep Meditation",
      description: "Guided journey into deep relaxation. Perfect before bedtime for restful sleep.",
      category: "sleep",
      difficulty: "beginner",
      duration: 20,
      tags: ["sleep", "bedtime", "rest"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "5-Minute Breathing Space",
      description: "Quick reset through mindful breathing. Anytime, anywhere practice.",
      category: "focus",
      difficulty: "beginner",
      duration: 5,
      tags: ["breathing", "quick", "reset"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "10-Minute Anxiety Relief",
      description: "Specific techniques to calm anxious thoughts and find peace in the present moment.",
      category: "anxiety",
      difficulty: "beginner",
      duration: 10,
      tags: ["anxiety", "calm", "peace"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "15-Minute Loving Kindness",
      description: "Cultivate compassion for yourself and others through traditional metta practice.",
      category: "self-compassion",
      difficulty: "intermediate",
      duration: 15,
      tags: ["compassion", "loving kindness", "metta"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "30-Minute Deep Meditation",
      description: "Extended practice for experienced meditators. Deep stillness and awareness.",
      category: "advanced",
      difficulty: "advanced",
      duration: 30,
      tags: ["deep", "advanced", "stillness"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "10-Minute Walking Meditation",
      description: "Mindful movement practice. Cultivate awareness through deliberate walking.",
      category: "movement",
      difficulty: "beginner",
      duration: 10,
      tags: ["walking", "movement", "mindfulness"],
      teacher: "TruResetX Coach",
      language: "English",
    },
    {
      title: "15-Minute Gratitude Practice",
      description: "Deep appreciation meditation. Connect with gratitude for life's blessings.",
      category: "gratitude",
      difficulty: "beginner",
      duration: 15,
      tags: ["gratitude", "appreciation", "positivity"],
      teacher: "TruResetX Coach",
      language: "English",
    },
  ];

  const batch = db.batch();
  const meditationsRef = db.collection("meditations");

  meditations.forEach((meditation) => {
    const docRef = meditationsRef.doc();
    batch.set(docRef, {
      ...meditation,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`✅ Seeded ${meditations.length} meditations`);
}

// ============================================
// 5. AMBIENT SOUNDS
// ============================================
async function seedAmbientSounds() {
  console.log("🔊 Seeding ambient sounds...");

  const sounds = [
    {
      name: "Rain on Leaves",
      type: "rain",
      duration_minutes: 60,
      description: "Gentle rainfall in a peaceful forest. Perfect for focus or sleep.",
    },
    {
      name: "Ocean Waves",
      type: "ocean",
      duration_minutes: 60,
      description: "Soothing ocean waves crashing on the shore. Calming and rhythmic.",
    },
    {
      name: "Forest Stream",
      type: "nature",
      duration_minutes: 60,
      description: "Babbling brook in a serene forest. Natural white noise for concentration.",
    },
    {
      name: "Crackling Fireplace",
      type: "fire",
      duration_minutes: 60,
      description: "Cozy fireplace sounds. Warm and comforting ambiance.",
    },
    {
      name: "Birds in Forest",
      type: "nature",
      duration_minutes: 60,
      description: "Morning birdsong in a peaceful forest. Uplifting natural sounds.",
    },
    {
      name: "Thunderstorm",
      type: "rain",
      duration_minutes: 60,
      description: "Distant thunder with gentle rain. Deep, atmospheric soundscape.",
    },
    {
      name: "Zen Garden",
      type: "ambient",
      duration_minutes: 60,
      description: "Minimal ambient tones. Perfect for meditation and deep work.",
    },
    {
      name: "Cafe Ambience",
      type: "ambient",
      duration_minutes: 60,
      description: "Soft cafe sounds. Background chatter and gentle activity.",
    },
  ];

  const batch = db.batch();
  const soundsRef = db.collection("ambient_sounds");

  sounds.forEach((sound) => {
    const docRef = soundsRef.doc();
    batch.set(docRef, {
      ...sound,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`✅ Seeded ${sounds.length} ambient sounds`);
}

// ============================================
// 6. CALENDAR EVENTS (check if exists)
// ============================================
async function seedCalendarEvents() {
  console.log("📅 Checking calendar events...");
  
  // Check if calendar events already exist (populateCalendarEvents might have run)
  const eventsSnapshot = await db.collection("calendar_events").limit(1).get();
  
  if (eventsSnapshot.empty) {
    console.log("📅 Calendar events collection is empty. Run populateCalendarEvents separately if needed.");
    console.log("   Calendar events (moon phases, festivals) should be populated by the populateCalendarEvents function.");
  } else {
    console.log("✅ Calendar events already exist, skipping...");
  }
}

// Run if called directly
if (require.main === module) {
  seedAllFeaturesData()
    .then(() => {
      console.log("✅ All features seeding finished successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Seeding error:", error);
      process.exit(1);
    });
}


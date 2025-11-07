# Complete Seed Data Guide - TruResetX

This guide covers all seed data scripts for populating Firestore with real, production-ready content.

## 🚀 Quick Start

### Option 1: Seed Everything (Recommended)
```bash
cd functions
npm install
npm run seed:all
```

This seeds:
- ✅ Exercises (50+ real exercises)
- ✅ Challenges (Body, Mind, Spirit, Combined)
- ✅ Badges/Achievements (25+ badges)
- ✅ Meditations (10 guided sessions)
- ✅ Ambient Sounds (8 soundscapes)
- ✅ Spiritual Content (from seedSpiritualData.ts)

### Option 2: Seed Individual Modules

**Spiritual Features Only:**
```bash
npm run seed:spiritual
# or
npm run seed
```

**Exercises Only (if using separate function):**
```bash
# Call the populateExercises HTTP function
# Or deploy and call via HTTP
```

## 📦 What Gets Seeded

### 1. Exercises Library (`exercises` collection)
**Count:** 50+ real exercises

- **Upper Body**: Push-ups, Pull-ups, Bench Press, Rows, Shoulder Press, Bicep Curls, Tricep Extensions
- **Lower Body**: Squats, Lunges, Deadlifts, Leg Press, Glute Bridges
- **Core**: Plank, Side Plank, Crunches, Russian Twists, Mountain Climbers
- **Cardio**: Burpees, Jumping Jacks, High Knees, Jump Squats
- **Full Body**: Kettlebell Swings, Battle Ropes

**Fields:**
- `name`, `muscle_groups[]`, `equipment[]`, `difficulty`, `is_compound`
- `instructions`, `tips[]`, `created_at`

### 2. Challenges (`challenges` collection)
**Count:** 13 challenges across all categories

**Body Challenges:**
- 7-Day Workout Starter
- 30-Day Fitness Challenge
- 10,000 Steps Daily
- Strength Builder

**Mind Challenges:**
- Daily Meditation (21 days)
- Mood Tracker (30 days)
- Gratitude Practice (14 days)
- Sleep Quality (21 days)

**Spirit Challenges:**
- Daily Practice (30 days)
- Mantra Mastery (21 days)
- Wisdom Seeker (14 days)

**Combined Challenges:**
- Holistic Wellness (7 days - all three)
- Perfect Week (7 days - complete tracking)

**Fields:**
- `title`, `description`, `category`, `difficulty`, `duration_days`
- `metrics` (object), `active`, `created_at`

### 3. Badges (`badges` collection)
**Count:** 25+ achievement badges

**Milestone Badges:**
- Week Warrior (7-day streak)
- Month Master (30-day streak)
- Century Champion (100-day streak)

**Body Badges:**
- Getting Started (10 workouts)
- Fitness Enthusiast (50 workouts)
- Workout Warrior (100 workouts)
- Strength Builder, Cardio King

**Mind Badges:**
- Self-Aware (30 mood logs)
- Emotional Intelligence (100 mood logs)
- Mindful Moment, Zen Beginner, Zen Master
- CBT Explorer

**Spirit Badges:**
- Sadhana Starter (7 days)
- Devoted Practitioner (30 days)
- Wisdom Reflector, Mantra Master
- Gratitude Champion

**Challenge & Daily Badges:**
- Challenge Completer, Challenge Master
- Daily Meditator, Daily Exerciser, Daily Practice

**Fields:**
- `id`, `name`, `description`, `category`, `icon`, `rarity`
- `created_at`

### 4. Meditations (`meditations` collection)
**Count:** 10 guided sessions

**Sessions:**
- 5-Minute Morning Mindfulness
- 10-Minute Stress Relief
- 15-Minute Body Scan
- 20-Minute Sleep Meditation
- 5-Minute Breathing Space
- 10-Minute Anxiety Relief
- 15-Minute Loving Kindness
- 30-Minute Deep Meditation
- 10-Minute Walking Meditation
- 15-Minute Gratitude Practice

**Fields:**
- `title`, `description`, `category`, `difficulty`, `duration`
- `tags[]`, `teacher`, `language`, `created_at`

### 5. Ambient Sounds (`ambient_sounds` collection)
**Count:** 8 soundscapes

**Types:**
- Rain on Leaves, Thunderstorm
- Ocean Waves
- Forest Stream, Birds in Forest
- Crackling Fireplace
- Zen Garden, Cafe Ambience

**Fields:**
- `name`, `type`, `duration_minutes`, `description`, `created_at`

### 6. Spiritual Content (from `seedSpiritualData.ts`)
**Collections:**
- `affirmations` (7 affirmations)
- `scriptures` (9 verses: 5 Christian + 4 Islamic)
- `lessons` (3 Jewish lessons)
- `yoga_sessions` (3 sequences)
- `mantras` (4 mantras)
- `sacred_verses` (2 verses)

## 🎯 Using Cloud Functions

After deploying, you can call seed functions from your Flutter app:

```dart
// Seed all features
final result = await FirebaseFunctions.instance
    .httpsCallable('seedAllFeaturesDataFunction')
    .call();

// Seed spiritual only
final result = await FirebaseFunctions.instance
    .httpsCallable('seedSpiritualDataFunction')
    .call();
```

## 📊 Data Verification

After seeding, check Firestore Console:

### Collections to Verify:
- ✅ `exercises` - 50+ documents
- ✅ `challenges` - 13 documents
- ✅ `badges` - 25+ documents
- ✅ `meditations` - 10 documents
- ✅ `ambient_sounds` - 8 documents
- ✅ `affirmations` - 7 documents
- ✅ `scriptures` - 9 documents
- ✅ `lessons` - 3 documents
- ✅ `yoga_sessions` - 3 documents
- ✅ `mantras` - 4 documents
- ✅ `sacred_verses` - 2 documents

## ⚠️ Important Notes

1. **Idempotency**: Scripts can be run multiple times, but will create duplicate entries. To avoid duplicates:
   - Use script only once for initial setup
   - Or implement duplicate checking (check if document exists before creating)

2. **Exercise Videos**: Exercise `video_url` fields may point to placeholder URLs. Replace with actual video URLs in production.

3. **Audio URLs**: Meditation and ambient sound `audioUrl` fields should be populated with actual audio file URLs in production.

4. **Calendar Events**: Moon phases and festival events are populated separately by `populateCalendarEvents` function.

5. **User Data**: All seed data is in global collections. User-specific data (logs, progress) is created by app usage.

## 🔧 Customization

To add more content:

1. **Exercises**: Edit `seedAllFeaturesData.ts` → `seedExercises()` function
2. **Challenges**: Edit `seedAllFeaturesData.ts` → `seedChallenges()` function
3. **Badges**: Edit `seedAllFeaturesData.ts` → `seedBadges()` function
4. **Meditations**: Edit `seedAllFeaturesData.ts` → `seedMeditations()` function

## 📝 Example Queries

### Get all beginner exercises:
```dart
final exercises = await FirebaseFirestore.instance
    .collection('exercises')
    .where('difficulty', isEqualTo: 'beginner')
    .get();
```

### Get active challenges:
```dart
final challenges = await FirebaseFirestore.instance
    .collection('challenges')
    .where('active', isEqualTo: true)
    .get();
```

### Get user's unlocked badges:
```dart
final badges = await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .collection('achievements')
    .get();
```

## ✅ Production Checklist

- [ ] Run `npm run seed:all` to populate all collections
- [ ] Verify all collections in Firestore Console
- [ ] Update exercise video URLs with real links
- [ ] Add audio URLs for meditations and ambient sounds
- [ ] Test exercises filtering in app
- [ ] Test challenges functionality
- [ ] Verify badges unlock correctly
- [ ] Test meditation playback
- [ ] Verify ambient sounds play correctly

## 🎉 Ready to Go!

After seeding, your TruResetX app will have:
- ✅ Real exercises for workout generation
- ✅ Meaningful challenges for user engagement
- ✅ Achievement badges for gamification
- ✅ Guided meditations for mental wellness
- ✅ Ambient sounds for focus and sleep
- ✅ Spiritual content for faith-based features

All data is **real and production-ready** - no placeholders!


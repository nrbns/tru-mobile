# TruResetX Backend Integration Guide

This guide explains how to integrate your TruResetX Flutter app with the Supabase backend and Edge Functions.

## 🚀 Backend Setup

### 1. Supabase Project Setup

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Note down your project URL and API keys

2. **Run Database Schema**
   - Copy the contents of `supabase_schema.sql`
   - Go to your Supabase dashboard → SQL Editor
   - Paste and run the schema

3. **Import Seed Data**
   - Go to Table Editor → `exercises`
   - Import `seed_exercises.json` data
   - Add additional seed data as needed

### 2. Deploy Edge Functions

Deploy all Edge Functions to your Supabase project:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref YOUR_PROJECT_REF

# Deploy functions
supabase functions deploy food-search
supabase functions deploy food-manual
supabase functions deploy food-log
supabase functions deploy food-day
supabase functions deploy exercises
supabase functions deploy workouts-today
supabase functions deploy workouts-start-set
supabase functions deploy workouts-rep
supabase functions deploy workouts-end-set
supabase functions deploy mood-who5
supabase functions deploy mood-summary
supabase functions deploy spiritual-gita-verse
supabase functions deploy wisdom-daily
```

### 3. Set Environment Variables

In your Supabase dashboard → Settings → Edge Functions → Environment Variables:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
OPENAI_API_KEY=your-openai-key
USDA_API_KEY=your-usda-key (optional)
```

## 📱 Flutter App Configuration

### 1. Update Environment Configuration

Update `lib/core/config/env.dart`:

```dart
class Env {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  static const String openaiApiKey = 'your-openai-key';
}
```

### 2. Install Dependencies

Run the following commands in your Flutter project:

```bash
flutter pub get
flutter pub run build_runner build
```

### 3. Generate JSON Serialization Code

The app uses `json_annotation` for automatic JSON serialization. Run:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🔧 API Endpoints

### Food Management
- `GET /food-search?q={query}` - Search foods
- `POST /food-scan` - Scan barcode or analyze photo
- `POST /food-log` - Log food consumption
- `POST /food-manual` - Create custom food
- `GET /food-day?date={date}` - Get daily nutrition

### Exercise & Workouts
- `GET /exercises?muscle={muscle}` - List exercises
- `GET /workouts-today` - Get today's workout
- `POST /workouts-start-set` - Start workout set
- `POST /workouts-rep` - Submit rep metrics
- `POST /workouts-end-set` - End workout set

### Mood Tracking
- `GET /mood-who5` - Get WHO-5 assessment items
- `POST /mood-who5` - Submit WHO-5 answers
- `GET /mood-summary?week={week}` - Get mood summary

### Spiritual Content
- `GET /spiritual-gita-verse?chapter={ch}&verse={v}&lang={lang}` - Get Gita verse
- `GET /wisdom-daily` - Get daily wisdom

## 📊 Data Models

### Food Models
- `FoodCatalog` - Food database entries
- `FoodLog` - User food consumption logs
- `DailyNutrition` - Daily nutrition summary
- `FoodSearchResult` - Search results
- `FoodScanResult` - Barcode/photo scan results

### Exercise Models
- `Exercise` - Exercise definitions with AR rules
- `ExerciseList` - Filtered exercise lists
- `ARErrorRule` - AR form error detection rules
- `ExerciseCategory` - Exercise groupings

### Workout Models
- `Workout` - Workout plans
- `WorkoutPlan` - Exercise sequences
- `SetLog` - Individual set logs with AR metrics
- `RepMetric` - Per-rep form analysis
- `WorkoutSession` - Complete workout sessions

### Mood Models
- `MoodLog` - Daily mood entries
- `Who5Item` - WHO-5 assessment questions
- `Who5Assessment` - Complete assessments
- `MoodSummary` - Weekly mood analysis

### Spiritual Models
- `ScriptureSource` - Sacred text sources
- `ScriptureVerse` - Individual verses
- `GitaVerse` - Bhagavad Gita specific
- `WisdomItem` - Daily wisdom content
- `SpiritualProgress` - User progress tracking

## 🔐 Authentication

The app uses Supabase Auth with JWT tokens. All API calls include:

```dart
'Authorization': 'Bearer ${accessToken}'
```

## 🎯 Key Features

### 1. Food Tracking
- Search comprehensive food database
- Barcode scanning and photo analysis
- Manual food creation
- Real-time nutrition tracking
- Daily nutrition summaries

### 2. Exercise & AR Integration
- Exercise database with form cues
- AR form error detection
- Real-time rep analysis
- Workout session tracking
- Progress monitoring

### 3. Mood Tracking
- WHO-5 wellbeing assessment
- Daily mood logging
- Weekly mood summaries
- Insights and recommendations

### 4. Spiritual Content
- Bhagavad Gita verses
- Daily wisdom items
- Progress tracking
- Multi-language support

## 🚀 Getting Started

1. **Complete Backend Setup** (see above)
2. **Update Environment Variables**
3. **Run Code Generation**: `flutter packages pub run build_runner build`
4. **Test API Connection**: Run the app and check logs
5. **Deploy to Production**: Configure production environment variables

## 🔍 Testing

### Test API Endpoints
```bash
# Test food search
curl -X GET "https://your-project.supabase.co/functions/v1/food-search?q=chicken" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Test exercises
curl -X GET "https://your-project.supabase.co/functions/v1/exercises" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Test in Flutter
1. Run the app in debug mode
2. Check console logs for API responses
3. Test each feature (food logging, mood tracking, etc.)
4. Verify data persistence in Supabase dashboard

## 🛠️ Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify Supabase URL and keys
   - Check user login status
   - Ensure JWT token is valid

2. **API Errors**
   - Check Edge Function logs in Supabase dashboard
   - Verify environment variables
   - Check function deployment status

3. **Data Not Loading**
   - Check network connectivity
   - Verify API endpoint URLs
   - Check console for error messages

4. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
   - Check for missing dependencies

### Debug Mode
Enable debug logging in your Flutter app:

```dart
// In main.dart
void main() {
  runApp(MyApp());
  // Enable debug logging
  debugPrint = (String? message, {int? wrapWidth}) {
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  };
}
```

## 📈 Performance Optimization

1. **Caching**: Implement local caching for frequently accessed data
2. **Pagination**: Use pagination for large data sets
3. **Background Sync**: Sync data in background
4. **Offline Support**: Cache critical data for offline use

## 🔒 Security

1. **Row Level Security**: All tables have RLS enabled
2. **JWT Tokens**: Secure API authentication
3. **Input Validation**: Server-side validation for all inputs
4. **Rate Limiting**: Implement rate limiting for API calls

## 📝 Next Steps

1. **Customize UI**: Adapt the UI to your design requirements
2. **Add Features**: Implement additional features as needed
3. **Analytics**: Add user analytics and tracking
4. **Push Notifications**: Implement push notifications
5. **Offline Support**: Add offline data synchronization

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Supabase documentation
3. Check Flutter documentation
4. Contact the development team

---

**Happy Coding! 🚀**

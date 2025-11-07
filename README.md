# TruResetX - Complete Holistic Wellness Platform

**The world's first holistic wellness platform combining AI-powered fitness coaching, mental health tracking, and spiritual growth for complete transformation.**

## 🌟 Features Overview

### 🥽 AR Workout Coach (Beta Available)
- **Real-time pose detection** with computer vision technology
- **Form correction feedback** with scoring system (1-100%)
- **Rep counting** and workout guidance
- **Camera integration** with AR overlay
- **Exercise-specific instructions** and video demonstrations

### 📱 Food Scan (Beta Available)
- **AI-powered food recognition** using camera and ML models
- **Instant nutrition analysis** with macro breakdown (calories, protein, carbs, fat)
- **Portion control** and calorie tracking
- **Gallery integration** for existing photos
- **Nutrition logging** with detailed metrics and trends

### 🧠 Mood & Psychometry (Live Now)
- **Advanced mood tracking** with 1-10 scales for mood, energy, and stress
- **Cognitive micro-games** (Reaction Time, Memory Challenge, Attention Test, Pattern Recognition)
- **Trend analysis** and wellness insights
- **Weekly overview** with progress tracking
- **Interactive assessment tools** for brain training

### 🤖 Multi-Persona AI Coach (Live Now)
- **4 Specialized Coaches**: Fitness (Alex), Nutrition (Dr. Maya), Mindfulness (Sage), Holistic (Phoenix)
- **Contextual recommendations** and real-time guidance
- **Tool-calling capabilities** for actions (generate workout, adjust macros, etc.)
- **Chat interface** with message history and quick actions
- **Action execution** with personalized responses

### 👥 Community Features (Coming Soon)
- **Accountability circles** for peer support and motivation
- **Progress sharing** and community feed
- **Circle management** with member tracking
- **Social wellness** and peer accountability
- **Progress sharing** with wellness updates

### 🧘 Spiritual & Wisdom (Live Now)
- **Guided meditation** with multiple durations (5-20 minutes)
- **Breathwork practices** (Box Breathing, 4-7-8, Wim Hof, Alternate Nostril)
- **Cultural wisdom** from different traditions (Buddhist, Stoic, Indigenous, Taoist)
- **Mindfulness exercises** and practices
- **Spiritual growth** and inner peace tools

## 🚀 Technical Architecture

### **Frontend Stack**
- **Flutter 3.0+** with Material 3 design
- **Riverpod** for state management
- **GoRouter** for navigation and deep linking
- **Hive** for offline-first local storage

### **Backend & AI**
- **Supabase** for database, authentication, and real-time features
- **OpenAI GPT-4** for AI coaching with tool-calling
- **Google ML Kit** for computer vision and food recognition
- **Flutter Local Notifications** for smart reminders

### **Advanced Features**
- **Offline-first architecture** with sync capabilities
- **Real-time notifications** for habits, workouts, and meditation
- **Data export/import** for user data portability
- **Multi-persona AI coaching** with specialized responses

## 📱 Project Structure

```
lib/
├── main.dart                    # App entry point with service initialization
├── app.dart                     # Main app configuration
├── core/                       # Core utilities and services
│   ├── env/                   # Environment configuration
│   ├── theme/                 # Material 3 theming system
│   ├── splash/                # Branded splash screen
│   ├── services/              # Core services (notifications, offline storage)
│   └── data/                  # Sample data and utilities
├── data/                      # Data layer
│   ├── models/               # Data models with JSON serialization
│   └── repositories/         # Repository implementations
├── features/                 # Feature modules
│   ├── auth/                # Authentication (email, Google, Apple)
│   ├── onboarding/          # User onboarding and goal setting
│   ├── ar_coach/            # AR Workout Coach with pose detection
│   ├── food_scan/           # AI-powered food recognition
│   ├── psychometry/         # Advanced mood tracking and cognitive games
│   ├── coach/               # Multi-persona AI coaching system
│   ├── community/           # Social features and accountability
│   ├── spiritual/           # Meditation, mindfulness, and wisdom
│   ├── workouts/            # Workout planning and tracking
│   ├── nutrition/           # Nutrition logging and tracking
│   ├── mood/                # Mood check-ins and trends
│   └── habits/              # Habit tracking with streaks
└── routing/                 # Navigation and deep linking
```

## 🛠️ Setup Instructions

### **Prerequisites**
1. **Flutter SDK 3.0+**: [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Android Studio**: For Android development
3. **Supabase Account**: [Create project](https://supabase.com)
4. **OpenAI API Key**: [Get API key](https://platform.openai.com)

### **Quick Start**
```bash
# Clone and setup
cd truresetx
flutter pub get

# Environment setup
cp env.example .env
# Edit .env with your API keys

# Database setup
# Run supabase_schema.sql in your Supabase SQL editor

# Run the app
flutter run
```

### **Environment Configuration**
```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# OpenAI Configuration  
OPENAI_API_KEY=your_openai_api_key_here

# Feature Flags
ENABLE_AI_COACH=true
ENABLE_HEALTH_SYNC=false
ENABLE_ANALYTICS=true
```

## 📊 Database Schema

The app uses Supabase with the following key tables:
- **profiles**: User information and preferences
- **workout_plans**: AI-generated workout plans
- **workouts & exercises**: Detailed exercise tracking
- **mood_checkins**: Mood, energy, and stress tracking
- **nutrition_logs**: Food and nutrition data
- **habits & habit_logs**: Habit tracking with streaks
- **ai_messages**: Chat history with AI coaches
- **coach_actions**: AI coach action execution

## 🎯 Feature Implementation Status

### ✅ **Completed (MVP Ready)**
- [x] **Authentication System** (Email, Google, Apple)
- [x] **Multi-Persona AI Coach** (4 specialized coaches)
- [x] **AR Workout Coach** (Pose detection framework)
- [x] **Food Scan** (AI recognition framework)
- [x] **Mood & Psychometry** (Advanced tracking + cognitive games)
- [x] **Spiritual & Wisdom** (Meditation, breathwork, cultural wisdom)
- [x] **Community Features** (Accountability circles, progress sharing)
- [x] **Offline Storage** (Hive-based with sync capabilities)
- [x] **Smart Notifications** (Habit reminders, meditation prompts)
- [x] **Sample Data** (Complete test dataset)

### 🔄 **In Development**
- [ ] **ML Model Integration** (Actual pose detection and food recognition)
- [ ] **Audio Meditation Files** (Guided meditation recordings)
- [ ] **Real-time Sync** (Supabase real-time subscriptions)
- [ ] **Advanced Analytics** (Progress tracking and insights)

### 📋 **Sprint Plan (4 Weeks)**

**Week 1: Core Features**
- [x] Authentication and onboarding
- [x] AI coach implementation
- [x] Basic workout and nutrition tracking

**Week 2: Advanced Features**  
- [x] AR workout coach framework
- [x] Food scan implementation
- [x] Mood tracking and cognitive games

**Week 3: Wellness & Community**
- [x] Spiritual and meditation features
- [x] Community and accountability circles
- [x] Notification system

**Week 4: Polish & Launch**
- [x] Offline storage and sync
- [x] Sample data and testing
- [x] Performance optimization

## 🔧 Development Commands

```bash
# Code generation (for models and providers)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build for release
flutter build apk --release
flutter build appbundle --release

# Analyze code
flutter analyze

# Format code
flutter format .
```

## 📱 App Screenshots & Features

### **Main Navigation**
- **5-tab structure**: Workouts, Coach, Nutrition, Mood, Spiritual
- **Seamless routing** between all features
- **Deep linking** support for specific workouts and features

### **AI Coach Experience**
- **Persona switching** between 4 specialized coaches
- **Quick actions** for common tasks
- **Action buttons** for executing coach recommendations
- **Chat history** with context-aware responses

### **AR Workout Coach**
- **Real-time camera preview** with pose detection overlay
- **Form scoring** and feedback system
- **Rep counting** and exercise guidance
- **Exercise-specific instructions**

### **Food Scan**
- **Camera integration** with food recognition
- **Nutrition breakdown** with macros and calories
- **Gallery support** for existing photos
- **Quick logging** to nutrition dashboard

## 🌟 Key Differentiators

1. **Holistic Approach**: First platform to combine fitness, nutrition, mental health, and spiritual growth
2. **AI-Powered**: Multi-persona coaching with specialized expertise
3. **AR Technology**: Real-time form correction and workout guidance
4. **Offline-First**: Works without internet with automatic sync
5. **Cultural Wisdom**: Integration of ancient wisdom with modern wellness
6. **Community-Driven**: Accountability circles and peer support

## 📈 Success Metrics

- **User Engagement**: Daily active users, session duration
- **Feature Adoption**: Usage rates for AR coach, food scan, meditation
- **Community Growth**: Active accountability circles, progress shares
- **Wellness Outcomes**: Mood improvements, habit streaks, goal achievement

## 🚀 Launch Strategy

1. **Beta Testing**: Internal testing with sample data
2. **Feature Validation**: User feedback on AR coach and food scan
3. **Community Building**: Early adopter program
4. **Full Launch**: App store release with all features

## 📞 Support & Contact

- **Email**: support@truresetx.com
- **Website**: https://truresetx.com
- **Documentation**: [Setup Guide](SETUP.md)

---

**TruResetX - Reset Your Body, Mind & Spirit** 🌟

*The world's first holistic wellness platform for complete transformation.*
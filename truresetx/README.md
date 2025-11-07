# TruResetX Flutter App

A comprehensive Flutter wellness application with advanced list management features.

## Features

- **Comprehensive List Management**: Create and manage different types of wellness lists
- **Multiple Item Types**: Tasks, Habits, Goals, Notes, and Reminders
- **Category Organization**: Fitness, Nutrition, Mental Health, Spiritual, Habits, Goals, and General
- **Progress Tracking**: Visual progress indicators and completion statistics
- **Priority System**: 5-level priority system for items
- **Tagging System**: Add custom tags to organize items
- **Material 3 Design**: Modern UI with Material 3 components
- **Offline Storage**: Local storage with Hive for offline-first experience

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd truresetx
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate code (for JSON serialization):
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app configuration
├── core/                        # Core utilities and services
│   ├── theme/                   # Material 3 theming
│   ├── services/                # Core services (notifications, storage)
│   └── data/                    # Sample data
├── data/                        # Data layer
│   ├── models/                  # Data models with JSON serialization
│   ├── repositories/            # Repository implementations
│   └── providers/               # Riverpod state management
├── features/                    # Feature modules
│   ├── home/                    # Home dashboard
│   ├── lists/                   # List management screens
│   └── profile/                 # User profile
└── routing/                     # Navigation and routing
```

## Key Features

### List Management
- Create custom wellness lists with categories
- Add items with different types (tasks, habits, goals, notes, reminders)
- Set priorities and add tags
- Track completion progress
- Visual progress indicators

### Categories
- **Fitness**: Workout routines, exercise tracking
- **Nutrition**: Meal planning, food logging
- **Mental Health**: Mood tracking, mindfulness practices
- **Spiritual**: Meditation, spiritual growth
- **Habits**: Daily habits and routines
- **Goals**: Long-term objectives
- **General**: Miscellaneous items

### Item Types
- **Tasks**: One-time activities to complete
- **Habits**: Recurring behaviors to track
- **Goals**: Long-term objectives to achieve
- **Notes**: Information and reminders
- **Reminders**: Time-based notifications

## Sample Data

The app includes comprehensive sample data to demonstrate all features:
- Morning workout routines
- Healthy meal prep lists
- Daily mindfulness practices
- Spiritual growth activities
- 2025 wellness goals
- Daily wellness habits

## State Management

Uses Riverpod for state management with:
- `listsProvider`: Manages all wellness lists
- `listByIdProvider`: Provides individual list data
- `completionStatsProvider`: Calculates completion statistics

## Storage

- **Hive**: Local database for offline-first experience
- **JSON Serialization**: Automatic serialization for data models
- **Repository Pattern**: Clean separation of data access logic

## Navigation

- **GoRouter**: Declarative routing with deep linking support
- **Bottom Navigation**: Easy access to main features
- **Material 3**: Modern navigation patterns

## Development

### Code Generation
Run the following command when models change:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Linting
The project uses Flutter Lints with custom rules for code quality.

### Testing
```bash
flutter test
```

### Building
```bash
# Debug build
flutter build apk

# Release build
flutter build apk --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

This project is part of the TruResetX holistic wellness platform.

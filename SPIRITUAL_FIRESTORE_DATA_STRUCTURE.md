# Spiritual Module - Firestore Data Structures

## Collections Reference

### User Collections (users/{uid}/...)

#### `gratitude_journals`
```javascript
{
  type: "gratitude" | "reflection",
  text: string,
  emotion_tags: string[],
  date: Timestamp,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

#### `karma_logs`
```javascript
{
  activity: string,
  impactScore: number, // -10 to +10
  reflection: string?,
  timestamp: Timestamp,
  category: "virtue" | "discipline" | "service" | ...
}
```

#### `yoga_sessions` (user history)
```javascript
{
  session_id: string,
  duration_minutes: number,
  difficulty_rating: number?,
  notes: string?,
  completed_poses: string[],
  completed_at: Timestamp
}
```

### Global Collections

#### `affirmations`
```javascript
{
  type: "healing" | "confidence" | "abundance" | ...,
  text: string,
  audioURL: string?,
  repeatCount: number,
  category: string
}
```

#### `scriptures`
```javascript
{
  tradition: "christian" | "islamic" | "jewish" | ...,
  text: string,
  translation: string,
  book?: string, // for Christian
  chapter?: number,
  verse?: number,
  surah?: string, // for Islamic
  ayah?: number,
  theme?: string
}
```

#### `devotionals`
```javascript
{
  tradition: "christian",
  title: string,
  audioURL: string?,
  verseRefs: string[],
  reflection: string
}
```

#### `lessons` (Jewish)
```javascript
{
  tradition: "jewish",
  topic: string,
  text: string,
  references: string[],
  videoURL: string?,
  category: "Torah" | "Talmud" | "Halacha" | ...
}
```

#### `yoga_sessions`
```javascript
{
  name: string,
  level: "beginner" | "intermediate" | "advanced",
  poses: YogaPose[],
  duration: number, // minutes
  videoURL: string?,
  focus: "flexibility" | "strength" | "relaxation" | ...,
  equipment: string[]
}
```

#### `yoga_poses`
```javascript
{
  name: string,
  category: "standing" | "seated" | "backbend" | ...,
  target_muscles: string[],
  description: string?,
  imageURL: string?,
  videoURL: string?
}
```

#### `prayer_times` (Islamic)
```javascript
{
  date: string, // YYYY-MM-DD key
  fajr: Timestamp,
  dhuhr: Timestamp,
  asr: Timestamp,
  maghrib: Timestamp,
  isha: Timestamp
}
```

#### `wisdom_posts`
```javascript
{
  quote: string,
  reflection: string?,
  practice_suggestion: string?,
  tradition: string?,
  date: Timestamp
}
```

## Cloud Functions Integration

All spiritual functions now use OpenAI/Gemini APIs:

- `getDailySpiritualStory` - Generates personalized parables
- `generateSoulGrowthSummary` - AI analysis of journal entries
- `getReflectionPrompt` - Personalized reflection questions
- `generateYogaSequence` - AI yoga routines
- `faithAIChat` - Faith-specific chatbot
- `generateDailySpiritualFeed` - Combined daily feed

## Usage Notes

1. **Fallback Data**: Services return fallback content when Firestore collections are empty (e.g., sample verses for Christian/Islamic modes)

2. **AI API Keys**: Configure via:
   ```bash
   firebase functions:secrets:set OPENAI_API_KEY
   firebase functions:secrets:set GEMINI_API_KEY
   ```

3. **User Traditions**: Stored in `users/{uid}/traditions` array from BeliefSetupScreen

4. **Real-time Updates**: Most services provide Stream methods for reactive UI updates


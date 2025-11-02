# API Integration & Navigation Fixes

## ✅ Fixed Issues

### 1. Navigation Fixed
- **Problem**: `SpiritHomeScreen` was using `Navigator.pushNamed()` which doesn't work with GoRouter
- **Solution**: Updated to use `context.push()` with proper route mapping
- **Files Changed**:
  - `lib/screens/spiritual/spirit_home_screen.dart` - Now uses GoRouter
  - `lib/screens/spirit/spirit_screen.dart` - Fixed Wisdom & Legends route to `/spirit/wisdom-legends`

### 2. Route Mapping
All spiritual feature routes are now properly mapped:
- `/spirit/wisdom-legends` → WisdomLegendsScreen ✓
- `/spirit/mantras` → MantrasLibraryScreen ✓
- `/spirit/audio-player` → AudioVersePlayerScreen ✓
- `/spirit/rituals` → RitualsTrackerScreen ✓
- `/spirit/calendar` → CalendarViewScreen ✓
- `/spirit/wisdom-feed` → WisdomFeedScreen ✓
- `/spirit/daily-practice` → DailyPracticeScreen ✓

### 3. RAG AI Agent Integration
**Status**: ✅ Implemented but needs deployment

**How it works**:
1. `RAGService` retrieves context from Firestore (mood logs, meals, workouts, spiritual practices)
2. `AIChatService` uses RAG context when `useRAG: true`
3. Cloud Function `chatCompletion` receives context and generates response

**Files**:
- `lib/core/services/rag_service.dart` - RAG implementation ✓
- `lib/core/services/ai_chat_service.dart` - Uses RAG ✓
- `functions/src/index.ts` - `chatCompletion` function ✓

### 4. Cloud Functions Status
**Functions Defined**:
- ✅ `chatCompletion` - AI chat with RAG context
- ✅ `domainAwareChat` - Domain-specific coaching
- ✅ `getDailySpiritualStory` - Spiritual content
- ✅ `generateSoulGrowthSummary` - Gratitude journal analysis
- ✅ `generateYogaSequence` - AI yoga sequences
- ✅ And many more...

**⚠️ IMPORTANT: Deploy Cloud Functions**

The functions are defined but must be deployed to Firebase:

```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

**Set API Keys** (Required):
```bash
# OpenAI (Primary)
firebase functions:secrets:set OPENAI_API_KEY
# When prompted, paste your OpenAI API key

# Optional: Gemini (Fallback)
firebase functions:secrets:set GEMINI_API_KEY
```

## 🔧 How Screens Work

### Wisdom & Legends Screen
- Fetches wisdom from Firestore `wisdom` collection
- Filters by author (Thirukkural, Gita, Rumi, etc.)
- Uses `legendsWisdomProvider` from `wisdom_provider.dart`

### Mantras Library Screen
- Fetches mantras from Firestore `mantras` collection
- Filters by tradition and category
- Uses `mantrasStreamProvider` for real-time updates

### Audio Verse Player Screen
- Streams sacred verses from Firestore `sacred_verses` collection
- Uses audio playback (just_audio package)
- Uses `sacredVersesProvider` for data

### Rituals Tracker Screen
- Shows user's spiritual practice logs
- Real-time updates via `practiceLogsStreamProvider`
- Data stored in `users/{uid}/practice_logs`

### Calendar View Screen
- Shows spiritual calendar events (moon phases, holidays)
- Uses `spiritualCalendarProvider`
- Data populated by `populateSpiritualCalendar` Cloud Function

## 🚨 Common Issues & Fixes

### Issue: "Screens not loading"
**Cause**: Missing Firestore data or provider errors
**Fix**: 
1. Check Firestore has data in collections
2. Verify providers are correctly wired
3. Check browser console for errors

### Issue: "API not working / RAG not working"
**Cause**: Cloud Functions not deployed or API keys not set
**Fix**:
1. Deploy functions: `firebase deploy --only functions`
2. Set API keys: `firebase functions:secrets:set OPENAI_API_KEY`
3. Restart app after deployment

### Issue: "Navigation not working"
**Cause**: Using Navigator instead of GoRouter
**Fix**: All navigation now uses `context.push()` with GoRouter

## 📝 Next Steps

1. **Deploy Cloud Functions** (Required for AI features)
2. **Seed Firestore Data** (Required for screens to show content):
   ```bash
   cd functions
   npm run seed:all
   ```
3. **Test Navigation**: All screens should now navigate correctly
4. **Test RAG**: Send a message in chatbot - should use context

## 🎯 Testing Checklist

- [ ] Wisdom & Legends screen loads
- [ ] Mantras Library shows mantras
- [ ] Audio Verse Player plays audio
- [ ] Rituals Tracker shows practice logs
- [ ] Calendar View shows calendar events
- [ ] Chatbot uses RAG context
- [ ] Cloud Functions respond correctly


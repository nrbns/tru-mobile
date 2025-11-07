# Security Audit & Action Items

## Critical Issues Found

### 1. ⚠️ AI Services Calling APIs Directly from Client

**Location**: 
- `lib/core/services/ai_service.dart`
- `lib/core/services/realtime_ai_service.dart`

**Issue**: These services are making direct HTTP calls to OpenAI API from the client app, exposing API keys in the client code.

**Risk**: 
- API keys can be extracted from the app
- No rate limiting or cost control
- Keys can be abused by malicious users

**Fix Required**:
1. **Move all AI API calls to Cloud Functions**
2. Client should only call Firebase Functions with user token
3. Functions handle API keys server-side using Firebase Secret Manager
4. Functions implement rate limiting and cost controls

**Example Migration**:
```dart
// ❌ OLD (Client-side - REMOVE)
final response = await http.post(
  Uri.parse('https://api.openai.com/v1/chat/completions'),
  headers: {'Authorization': 'Bearer $_apiKey'},
  body: jsonEncode(requestBody),
);

// ✅ NEW (Client-side - USE THIS)
final response = await FirebaseFunctions.instance
  .httpsCallable('chatCompletion')
  .call({
    'prompt': prompt,
    'persona': persona,
  });
```

**Cloud Function Example** (functions/src/index.ts):
```typescript
import * as functions from 'firebase-functions';
import {OpenAI} from 'openai';

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

export const chatCompletion = functions.https.onCall(async (data, context) => {
  // Verify auth
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  // Rate limiting check
  // Cost control
  // Call OpenAI
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{role: 'user', content: data.prompt}],
  });
  
  return {content: completion.choices[0].message.content};
});
```

### 2. ✅ Firestore Rules - FIXED

**Status**: Updated with:
- Per-user scoping for all collections
- Entitlements collection for premium gating (server-side only)
- Public catalogs read-only
- Deny all by default

**Action**: Deploy updated rules:
```bash
firebase deploy --only firestore:rules
```

### 3. ✅ Storage Rules - FIXED

**Status**: Updated with:
- User-specific uploads scoped to owner
- Public content read-only
- Temp files for processing
- Deny all by default

**Action**: Deploy updated rules:
```bash
firebase deploy --only storage
```

### 4. ⚠️ App Check Not Enabled

**Issue**: Firebase App Check is not configured, allowing unauthorized access.

**Fix Required**:
1. Enable App Check in Firebase Console
2. Configure for Android (Play Integrity) and iOS (App Attest)
3. Update Firestore/Storage rules to require App Check:
```javascript
function isAppVerified() {
  return request.app != null && request.app.verificationState == 'APP_VERIFIED';
}

// Add to rules:
allow read, write: if isAuthenticated() && isOwner(uid) && isAppVerified();
```

### 5. ✅ Environment Variables - SECURE

**Status**: API keys are loaded from environment variables, not hardcoded.

**Note**: Still need to migrate AI calls to Cloud Functions (see #1).

## Provider Lifecycle - FIXED

**Status**: Updated `list_providers.dart` to use:
- `autoDispose` for automatic cleanup
- `ref.keepAlive()` for tab data to prevent refetch

**Action**: Apply same pattern to other providers:
- `moodLogsProvider`
- `workoutLogsProvider`
- `nutritionLogsProvider`
- All other tab-scoped providers

## Empty States & Error Handling - ADDED

**Status**: Created reusable widgets:
- `EmptyState` - Generic empty state
- `EmptyListState` - For lists
- `EmptyLogsState` - For log screens
- `ErrorState` - Error display with retry
- `ErrorCard` - Inline error display

**Action**: Integrate into all loggable screens:
- Mood tracking
- Food tracking
- Workout logging
- Weight logging
- Spiritual practices

## Linting - IMPROVED

**Status**: Updated `analysis_options.yaml` with strict rules:
- `avoid_print: true`
- `unawaited_futures: true`
- `always_use_package_imports: true`
- `prefer_final_locals: true`
- And many more best practices

**Action**: Run `dart analyze` and fix all warnings.

## CI/CD - ADDED

**Status**: Created GitHub Actions workflow:
- Code analysis on PR
- Tests with coverage
- Android build
- iOS build

**Action**: Enable in GitHub repository settings.

## Next Steps Priority

1. **HIGH**: Migrate AI services to Cloud Functions (security risk)
2. **HIGH**: Enable App Check in Firebase
3. **MEDIUM**: Apply provider patterns to all providers
4. **MEDIUM**: Add empty states to all screens
5. **LOW**: Set up flavors (dev/staging/prod)


# TruResetX Blade API

Minimal Node + Express API that verifies Firebase ID tokens, exposes an AI coach endpoint, and ingests progress to Firestore via Admin SDK.

## Quick start

1) Set credentials
- Use Google ADC or set `GOOGLE_APPLICATION_CREDENTIALS` to a service account JSON.
- Optionally set AI keys:
```
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...
```

2) Install & run
```
npm ci
npm run dev
```

3) Endpoints
- GET /health
- POST /ai/coach (Bearer <Firebase ID token>)
  body: { goal, currentWeight, mood, message }
- POST /progress/ingest (Bearer)
  body: { type: 'workout'|'meal'|'mood', payload: {...} }

Deploy to Render/Vercel/Cloud Run. Ensure env vars are set and Firebase Admin can initialize.

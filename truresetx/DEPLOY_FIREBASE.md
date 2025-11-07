This document shows how to upload/deploy the TruResetX Flutter project to Firebase (Hosting + Cloud Functions).

Prerequisites (on your Windows machine):
- Node.js (18.x recommended)
- npm (comes with Node)
- Flutter SDK (to build web)
- The FlutterFire CLI has already been run and `lib/firebase_options.dart` exists.

Recommended commands (PowerShell):

# 1) Install Firebase CLI (one-time)
npm install -g firebase-tools

# 2) Authenticate your machine with Firebase
firebase login

# 3) Ensure the default project is set (we created truresetx-lite).
firebase use --add
# Select the project id `truresetx-lite` and create an alias (e.g. `default`).

# 4) Install functions dependencies
cd functions
npm install
cd ..

# 5) Build the Flutter web app
flutter build web --release
# This writes output to build/web which is referenced by firebase.json hosting config

# 6) Deploy Hosting and Cloud Functions
firebase deploy --only hosting,functions

Notes and security
- The `functions/index.js` created here is a demo stub and should not be used as-is in production; add auth checks (Firebase Auth ID tokens or Callable functions), rate limits, logging, and secure any LLM/API keys via environment variables.
- If you plan to use Firestore, add appropriate security rules and indexes (create `firestore.rules` and `firestore.indexes.json`).
- For CI/CD, create a service account and run `firebase deploy --token "$FIREBASE_TOKEN"` from your pipeline.

If you'd like, I can:
- Create `firestore.rules` and a simple ruleset tailored for your schema.
- Add a callable function instead of an HTTP function (safer) and show how to call it from Flutter.
- Run deploy steps here if you provide credentials; otherwise run the steps above locally and tell me any errors to fix.

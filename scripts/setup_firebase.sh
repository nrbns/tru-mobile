#!/bin/bash

# TruResetX Firebase Setup Script
# Run this script to configure Firebase for your project

echo "🔥 TruResetX Firebase Setup Script"
echo "=================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    echo "❌ FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
fi

echo ""
echo "Step 1: Firebase Login"
echo "----------------------"
echo "Please login to Firebase..."
firebase login

echo ""
echo "Step 2: Initialize Firebase"
echo "----------------------------"
echo "Select: Firestore, Functions, Storage"
echo "Use existing project"
echo "Select your Firebase project"
firebase init

echo ""
echo "Step 3: Configure Flutter"
echo "-------------------------"
echo "Run: flutterfire configure"
echo "Select your project and platforms"
flutterfire configure

echo ""
echo "Step 4: Install Dependencies"
echo "-----------------------------"
flutter pub get
cd functions && npm install && cd ..

echo ""
echo "Step 5: Deploy Security Rules"
echo "------------------------------"
firebase deploy --only firestore:rules,storage

echo ""
echo "Step 6: Deploy Functions"
echo "------------------------"
cd functions
npm run build
cd ..
firebase deploy --only functions

echo ""
echo "✅ Firebase setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .firebaserc with your project ID"
echo "2. Verify firebase_options.dart was generated"
echo "3. Run: flutter run"
echo "4. Test authentication and Firestore"


# TruResetX Firebase Setup Script (PowerShell)
# Run this script to configure Firebase for your project

Write-Host "🔥 TruResetX Firebase Setup Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase CLI is installed
try {
    firebase --version | Out-Null
    Write-Host "✅ Firebase CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g firebase-tools
}

# Check if FlutterFire CLI is installed
try {
    flutterfire --version | Out-Null
    Write-Host "✅ FlutterFire CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ FlutterFire CLI not found. Installing..." -ForegroundColor Yellow
    dart pub global activate flutterfire_cli
}

Write-Host ""
Write-Host "Step 1: Firebase Login" -ForegroundColor Yellow
Write-Host "----------------------"
Write-Host "Please login to Firebase..."
firebase login

Write-Host ""
Write-Host "Step 2: Initialize Firebase" -ForegroundColor Yellow
Write-Host "----------------------------"
Write-Host "When prompted, select:"
Write-Host "  - Firestore: Yes"
Write-Host "  - Functions: Yes"
Write-Host "  - Storage: Yes"
Write-Host "  - Use existing project"
Write-Host "  - Select your Firebase project"
Write-Host ""
Read-Host "Press Enter to continue"
firebase init

Write-Host ""
Write-Host "Step 3: Configure Flutter" -ForegroundColor Yellow
Write-Host "-------------------------"
Write-Host "Running flutterfire configure..."
Write-Host "Select your project and platforms (Android & iOS)"
flutterfire configure

Write-Host ""
Write-Host "Step 4: Install Dependencies" -ForegroundColor Yellow
Write-Host "-----------------------------"
flutter pub get
Set-Location functions
npm install
Set-Location ..

Write-Host ""
Write-Host "Step 5: Deploy Security Rules" -ForegroundColor Yellow
Write-Host "------------------------------"
firebase deploy --only firestore:rules,storage

Write-Host ""
Write-Host "Step 6: Build Functions" -ForegroundColor Yellow
Write-Host "------------------------"
Set-Location functions
npm run build
Set-Location ..

Write-Host ""
Write-Host "Step 7: Deploy Functions" -ForegroundColor Yellow
Write-Host "------------------------"
firebase deploy --only functions

Write-Host ""
Write-Host "✅ Firebase setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update .firebaserc with your actual project ID"
Write-Host "2. Verify firebase_options.dart was generated in lib/"
Write-Host "3. Run: flutter run"
Write-Host "4. Test authentication and Firestore"


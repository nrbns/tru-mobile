Release signing and Play Store launch steps

1) Create a keystore (example using keytool):

   mkdir -p keystore
   keytool -genkey -v -keystore keystore/release.keystore -alias truresetx_key -keyalg RSA -keysize 2048 -validity 10000

2) Create `android/key.properties` (DO NOT CHECK THIS INTO GIT). Use `android/key.properties.example` as a template.

3) Update `android/app/build.gradle.kts` will automatically load `key.properties` if present and apply signingConfig for "release" build.

4) Build a release AAB (recommended for Play Store):

   cd truresetx
   flutter build appbundle --release

5) Test the release AAB locally (bundletool or internal testing track in Play Console).

6) Upload AAB to Play Console, follow store listing, content, privacy policy, and target audience.

Checklist for Play Store readiness
- [ ] App bundle (.aab) created and signed with release key
- [ ] Privacy policy URL added in Play Console and inside app if handling personal data
- [ ] Target SDK and min SDK tested (minSdk currently set to 26)
- [ ] Appropriate permissions documented (INTERNET, CAMERA, etc.)
- [ ] App icon and store graphics ready (512x512 icon, feature graphic)
- [ ] VersionCode/VersionName set in Gradle (uses Flutter's version)
- [ ] ProGuard/R8 config considered if using native code or third-party SDKs
- [ ] Monetization/tax settings configured in Play Console if applicable

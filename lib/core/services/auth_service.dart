import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/today_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Attempts to sign in with email & password. If the account doesn't exist
  /// (FirebaseAuthException.code == 'user-not-found') this will create a new
  /// account using the provided [name] or a sensible default derived from the
  /// email address.
  Future<UserCredential> signInOrCreateWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      return await signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        final displayName = name ?? _displayNameFromEmail(email);
        return await signUpWithEmailAndPassword(
          name: displayName,
          email: email,
          password: password,
        );
      }

      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(name);
      await _createUserProfile(credential.user!.uid, name, email);
    }

    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null &&
        userCredential.additionalUserInfo?.isNewUser == true) {
      await _createUserProfile(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? 'User',
        null,
        phone: userCredential.user!.phoneNumber,
      );
    }

    return userCredential;
  }

  Future<void> _createUserProfile(
    String uid,
    String name,
    String? email, {
    String? phone,
  }) async {
    final userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      goals: [],
      traditions: [],
      settings: UserSettings(
        eveningCheckin: true,
        hydrationReminders: true,
        practiceReminders: true,
        timezone: 'Asia/Kolkata',
        push: NotificationSettings(
          enabled: true,
          eveningReflection: true,
          hydrationNudges: true,
          sadhanaReminders: true,
        ),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(userModel.toFirestore());

    // Initialize today document
    await _initializeToday(uid);
  }

  Future<void> _initializeToday(String uid) async {
    final todayRef =
        _firestore.collection('users').doc(uid).collection('today').doc(
              _getTodayKey(),
            );

    final todayData = TodayModel(
      uid: uid,
      date: DateTime.now(),
      streak: 0,
      calories: 0,
      waterMl: 0,
      workouts: WorkoutStatus(done: 0, target: 1),
      mood: MoodStatus(),
      sadhana: SadhanaStatus(done: 0, target: 3, completedPractices: []),
      updatedAt: DateTime.now(),
    );

    await todayRef.set(todayData.toFirestore());
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _displayNameFromEmail(String email) {
    try {
      final local = email.split('@').first;
      final parts =
          local.split(RegExp(r'[._\-]')).where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return 'User';
      return parts
          .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
          .join(' ');
    } catch (_) {
      return 'User';
    }
  }
}

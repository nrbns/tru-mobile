import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_repository.dart';

class FirebaseAuthAdapter implements AuthRepository {
  FirebaseAuthAdapter._();
  static final FirebaseAuthAdapter instance = FirebaseAuthAdapter._();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  @override
  Future<void> initialize() async {
    // Ensure Firebase core is initialized. If the app already initializes
    // Firebase elsewhere, this will be a no-op.
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // ignore: avoid_print
      print('Firebase.initializeApp() threw; it may already be initialized.');
    }
  }

  @override
  Future<dynamic> signUp(
      {required String email,
      required String password,
      String? fullName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (fullName != null) {
      await cred.user?.updateDisplayName(fullName);
    }
    return cred;
  }

  @override
  Future<dynamic> signIn(
      {required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return cred;
  }

  @override
  Future<void> signInWithGoogle() async {
    // Perform Google Sign-In and authenticate with Firebase.
    final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
    if (googleUser == null) throw Exception('Google sign in aborted');

    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signInWithApple() async {
    // Apple sign-in requires platform-specific configuration. Provide a
    // placeholder to avoid runtime errors; implement platform flows if
    // you need Apple Sign-In.
    throw UnimplementedError('Apple sign-in via Firebase is not implemented.');
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Stream<dynamic> get authStateChanges => _auth.authStateChanges();

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  String? get currentUserId => _auth.currentUser?.uid;
}

final firebaseAuthAdapterProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthAdapter.instance;
});

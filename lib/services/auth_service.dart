import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Wraps FirebaseAuth for the Teacher App. Every screen should go
/// through this instead of calling FirebaseAuth directly, so error
/// handling and the `teachers/{uid}` profile doc stay in one place.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Fires whenever sign-in state changes — use this to drive the
  /// Splash/AuthWrapper redirect instead of checking currentUser once.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------- Sign in ----------

  Future<User?> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  // ---------- Sign up ----------

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      await user.updateDisplayName(name.trim());

      // Free-tier verification: Firebase emails the link itself, no
      // Cloud Function / Blaze plan needed.
      await user.sendEmailVerification();

      await _db.collection('teachers').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  // ---------- Password reset ----------

  /// Sends Firebase's own reset-link email. Free on the Spark plan —
  /// no custom OTP/Cloud Function involved.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  // ---------- Sign out ----------

  Future<void> signOut() => _auth.signOut();

  // ---------- Error messages ----------

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak — use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a bit.';
      case 'network-request-failed':
        return 'Network error — please check your internet connection.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
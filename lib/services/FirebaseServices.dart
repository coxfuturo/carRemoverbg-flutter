import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user is logged in
  static User? get currentUser => _auth.currentUser;

  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

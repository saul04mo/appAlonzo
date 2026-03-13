import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Data source que encapsula FirebaseAuth y GoogleSignIn.
class AuthDataSource {
  final FirebaseAuth _auth;

  AuthDataSource({required FirebaseAuth auth}) : _auth = auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Fuerza el selector de cuentas
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createAccount(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> reloadUser() async => _auth.currentUser?.reload();
}

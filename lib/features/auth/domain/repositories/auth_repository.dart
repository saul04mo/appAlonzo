import 'package:firebase_auth/firebase_auth.dart';

/// Contrato del repositorio de autenticación.
///
/// La capa de dominio solo conoce esta interfaz abstracta.
abstract class AuthRepository {
  /// Stream que emite el usuario actual al cambiar el estado de autenticación.
  Stream<User?> authStateChanges();

  /// Inicia sesión con cuenta de Google.
  Future<void> signInWithGoogle();

  /// Inicia sesión con correo y contraseña.
  Future<void> signInWithEmail(String email, String password);

  /// Crea una nueva cuenta con correo y contraseña.
  Future<void> createAccount(String email, String password);

  /// Cierra la sesión actual.
  Future<void> signOut();
}

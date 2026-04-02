import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/providers.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

/// Estado de autenticación de la app.
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith(
      {AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier principal de autenticación.
///
/// Solo conoce [AuthRepository] — sin imports de FirebaseAuth directos.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _repo.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          await user.reload();
          // ignore: use_build_context_synchronously
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
          );
        } catch (e) {
          final errorStr = e.toString().toLowerCase();
          // Si el error es de red (común en emuladores), NO cerramos sesión.
          // Solo cerramos si el usuario es inválido o fue eliminado.
          if (errorStr.contains('network') || errorStr.contains('unavailable') || errorStr.contains('deadline')) {
            state = AuthState(
              status: AuthStatus.authenticated,
              user: user,
            );
          } else {
            await _repo.signOut();
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
        }
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  /// Inicia sesión con Google.
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _repo.signInWithGoogle();
    } catch (e) {
      final msg = e.toString().contains('cancelled')
          ? null
          : 'Error al iniciar sesión con Google: $e';
      state = AuthState(
        status: msg != null ? AuthStatus.error : AuthStatus.unauthenticated,
        errorMessage: msg,
      );
    }
  }

  /// Inicia sesión con correo y contraseña.
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _repo.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al iniciar sesión: $e',
      );
    }
  }

  /// Crea cuenta con correo y contraseña.
  Future<void> createAccount(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _repo.createAccount(email, password);
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al crear cuenta: $e',
      );
    }
  }

  /// Cierra sesión.
  Future<void> signOut() => _repo.signOut();

  /// Mensajes de error amigables en español.
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo. ¿Quieres crear una cuenta?';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña incorrecta. Intenta de nuevo.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo. Intenta iniciar sesión.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu conexión.';
      default:
        return 'Error de autenticación. Intenta de nuevo.';
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Provider del repositorio de autenticación.
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    dataSource: AuthDataSource(auth: ref.read(firebaseAuthProvider)),
  );
});

/// Provider global de autenticación.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/providers.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../data/datasources/user_profile_firestore_datasource.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════
//  ESTADO
// ═══════════════════════════════════════════════════════════

/// Estado del perfil de usuario.
class UserProfileState {
  final UserProfile profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool profileLoaded;

  const UserProfileState({
    this.profile = const UserProfile(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.profileLoaded = false,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? profileLoaded,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      profileLoaded: profileLoaded ?? this.profileLoaded,
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  NOTIFIER
// ═══════════════════════════════════════════════════════════

/// Notifier para gestionar el perfil del usuario.
///
/// Solo conoce [UserProfileRepository] — sin imports de Firebase.
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileRepository _repo;

  UserProfileNotifier(this._repo) : super(const UserProfileState()) {
    _loadProfile();
  }

  /// Carga el perfil del usuario a través del repositorio.
  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _repo.getProfile();
      if (!mounted) return;
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        profileLoaded: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        profileLoaded: true,
        errorMessage: 'Error al cargar perfil: $e',
      );
    }
  }

  /// Guarda el perfil del usuario a través del repositorio.
  Future<bool> saveProfile(UserProfile profile) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repo.saveProfile(profile);
      if (!mounted) return false;
      state = state.copyWith(
        profile: profile,
        isSaving: false,
        profileLoaded: true,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error al guardar perfil: $e',
      );
      return false;
    }
  }

  /// Recarga el perfil (útil después de login).
  Future<void> reload() async => _loadProfile();
}

// ═══════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Provider del repositorio de perfil.
final userProfileRepositoryProvider =
    Provider<UserProfileRepositoryImpl>((ref) {
  return UserProfileRepositoryImpl(
    dataSource: UserProfileFirestoreDataSource(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(firebaseAuthProvider),
    ),
  );
});

/// Provider global del perfil de usuario.
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  // Observar el estado de auth para recrear el provider al iniciar/cerrar sesión
  ref.watch(authNotifierProvider);
  return UserProfileNotifier(ref.read(userProfileRepositoryProvider));
});

import '../../../auth/domain/entities/user_profile_entity.dart';

/// Contrato del repositorio del perfil de usuario.
///
/// La capa de dominio solo conoce esta interfaz abstracta.
/// La implementación concreta vive en `data/repositories/`.
abstract class UserProfileRepository {
  /// Carga el perfil del usuario actual desde Firestore.
  /// Si no existe, retorna un perfil vacío pre-llenado con datos de Auth.
  Future<UserProfile> getProfile();

  /// Guarda (merge) el perfil en Firestore.
  Future<void> saveProfile(UserProfile profile);

  /// Busca un cliente por cédula/RIF. Retorna null si no existe.
  Future<Map<String, dynamic>?> searchByRifCi(String rifCi);

  /// Verifica si el usuario tiene perfil con nombre en Firestore.
  Future<bool> checkProfileExists();
}

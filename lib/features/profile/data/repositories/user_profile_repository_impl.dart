import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_firestore_datasource.dart';

/// Implementación concreta del repositorio de perfil de usuario.
///
/// Delega todas las operaciones al [UserProfileFirestoreDataSource].
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileFirestoreDataSource _dataSource;

  UserProfileRepositoryImpl(
      {required UserProfileFirestoreDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<UserProfile> getProfile() => _dataSource.getProfile();

  @override
  Future<void> saveProfile(UserProfile profile) =>
      _dataSource.saveProfile(profile);

  @override
  Future<Map<String, dynamic>?> searchByRifCi(String rifCi) =>
      _dataSource.searchByRifCi(rifCi);

  @override
  Future<bool> checkProfileExists() => _dataSource.checkProfileExists();
}

import '../../../catalog/domain/entities/product_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_firestore_datasource.dart';

/// Implementación concreta del repositorio de favoritos.
///
/// Delega todas las operaciones al [FavoritesFirestoreDataSource].
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesFirestoreDataSource _dataSource;

  FavoritesRepositoryImpl({required FavoritesFirestoreDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<ProductEntity>> getFavorites() => _dataSource.getFavorites();

  @override
  Future<void> addFavorite(String productId) =>
      _dataSource.addFavorite(productId);

  @override
  Future<void> removeFavorite(String productId) =>
      _dataSource.removeFavorite(productId);

  /// Carga un producto individual (usado al hacer toggle "agregar").
  Future<ProductEntity?> getProductById(String productId) =>
      _dataSource.getProductById(productId);
}

import '../../../catalog/domain/entities/product_entity.dart';

/// Contrato del repositorio de favoritos.
///
/// La capa de dominio solo conoce esta interfaz abstracta.
/// La implementación concreta vive en `data/repositories/`.
abstract class FavoritesRepository {
  /// Carga los IDs y productos completos favoritos del usuario actual.
  Future<List<ProductEntity>> getFavorites();

  /// Agrega un producto a la lista de favoritos.
  Future<void> addFavorite(String productId);

  /// Elimina un producto de la lista de favoritos.
  Future<void> removeFavorite(String productId);
}

import '../entities/product_entity.dart';

/// Contrato del repositorio de productos.
///
/// La capa de dominio solo conoce esta interfaz abstracta.
/// La implementación concreta vive en `data/repositories/`.
abstract class ProductRepository {
  /// Stream reactivo de productos filtrados por género.
  Stream<List<ProductEntity>> watchProductsByGender(String gender);

  /// Obtiene productos por género (una sola lectura).
  Future<List<ProductEntity>> getProductsByGender(String gender);

  /// Obtiene un producto individual por su ID.
  Future<ProductEntity?> getProductById(String productId);

  /// Obtiene productos filtrados por categoría y género.
  Future<List<ProductEntity>> getProductsByCategory(
    String category,
    String gender,
  );

  /// Busca productos por nombre (search).
  Future<List<ProductEntity>> searchProducts(String query);
}

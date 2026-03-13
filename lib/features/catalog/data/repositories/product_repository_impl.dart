import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_firestore_datasource.dart';

/// Implementación concreta del repositorio de productos.
///
/// Delega todas las operaciones al [ProductFirestoreDataSource].
/// En el futuro, aquí se puede agregar caché local con Hive o similar.
class ProductRepositoryImpl implements ProductRepository {
  final ProductFirestoreDataSource _dataSource;

  ProductRepositoryImpl({ProductFirestoreDataSource? dataSource})
      : _dataSource = dataSource ?? ProductFirestoreDataSource();

  @override
  Stream<List<ProductEntity>> watchProductsByGender(String gender) {
    return _dataSource.watchByGender(gender);
  }

  @override
  Future<List<ProductEntity>> getProductsByGender(String gender) {
    return _dataSource.getByGender(gender);
  }

  @override
  Future<ProductEntity?> getProductById(String productId) {
    return _dataSource.getById(productId);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
      String category, String gender) {
    return _dataSource.getByCategory(category, gender);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) {
    return _dataSource.search(query);
  }
}

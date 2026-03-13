import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/product_firestore_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// ═══════════════════════════════════════════════════════════
//  DEPENDENCY INJECTION
// ═══════════════════════════════════════════════════════════

final productDataSourceProvider = Provider<ProductFirestoreDataSource>((ref) {
  return ProductFirestoreDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    dataSource: ref.watch(productDataSourceProvider),
  );
});

// ═══════════════════════════════════════════════════════════
//  STREAMS REACTIVOS POR GÉNERO
// ═══════════════════════════════════════════════════════════

/// Stream de productos para Mujer.
final womenProductsProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider).watchProductsByGender('Mujer');
});

/// Stream de productos para Hombre.
final menProductsProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider).watchProductsByGender('Hombre');
});

/// Stream de productos para Niños.
final kidsProductsProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider).watchProductsByGender('Niños');
});

/// Provider paramétrico: productos por género dinámico.
final productsByGenderProvider =
    StreamProvider.family<List<ProductEntity>, String>((ref, gender) {
  return ref.watch(productRepositoryProvider).watchProductsByGender(gender);
});

// ═══════════════════════════════════════════════════════════
//  PRODUCTO INDIVIDUAL (PDP)
// ═══════════════════════════════════════════════════════════

/// Provider para obtener un producto por su ID.
final productByIdProvider =
    FutureProvider.family<ProductEntity?, String>((ref, id) {
  return ref.watch(productRepositoryProvider).getProductById(id);
});

// ═══════════════════════════════════════════════════════════
//  BÚSQUEDA
// ═══════════════════════════════════════════════════════════

/// Término de búsqueda actual.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Resultados de búsqueda reactivos.
final searchResultsProvider = FutureProvider<List<ProductEntity>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return Future.value([]);
  return ref.watch(productRepositoryProvider).searchProducts(query);
});

// ═══════════════════════════════════════════════════════════
//  SELECCIÓN DE VARIANTE EN PDP
// ═══════════════════════════════════════════════════════════

/// Talla seleccionada actualmente en el PDP.
final selectedSizeProvider = StateProvider<String?>((ref) => null);

/// Color seleccionado actualmente en el PDP.
final selectedColorProvider = StateProvider<String?>((ref) => null);

/// Variante seleccionada basada en talla + color.
final selectedVariantProvider = Provider<ProductVariantEntity?>((ref) {
  // Este provider se consume dentro del PDP con acceso al producto actual.
  // Se combina con selectedSizeProvider y selectedColorProvider.
  return null; // Se inicializa en el widget del PDP.
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/providers.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../data/datasources/favorites_firestore_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Estado de favoritos del usuario.
class FavoritesState {
  final Set<String> productIds;
  final List<ProductEntity> products;
  final bool isLoading;

  const FavoritesState({
    this.productIds = const {},
    this.products = const [],
    this.isLoading = true,
  });

  FavoritesState copyWith({
    Set<String>? productIds,
    List<ProductEntity>? products,
    bool? isLoading,
  }) {
    return FavoritesState(
      productIds: productIds ?? this.productIds,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorite(String productId) => productIds.contains(productId);
}

/// Notifier que maneja la lista de favoritos.
///
/// Solo conoce [FavoritesRepository] — sin imports de Firebase.
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepositoryImpl _repo;

  FavoritesNotifier(this._repo) : super(const FavoritesState()) {
    _loadFavorites();
  }

  /// Carga los favoritos del usuario a través del repositorio.
  Future<void> _loadFavorites() async {
    try {
      final products = await _repo.getFavorites();
      if (!mounted) return;
      state = FavoritesState(
        productIds: products.map((p) => p.id).toSet(),
        products: products,
        isLoading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = const FavoritesState(isLoading: false);
    }
  }

  /// Alterna favorito (agrega o quita) con actualización optimista de UI.
  Future<void> toggle(String productId) async {
    if (state.isFavorite(productId)) {
      // Quitar de favoritos (optimista)
      final newIds = Set<String>.from(state.productIds)..remove(productId);
      final newProducts =
          state.products.where((p) => p.id != productId).toList();
      state = state.copyWith(productIds: newIds, products: newProducts);

      await _repo.removeFavorite(productId);
    } else {
      // Agregar a favoritos (optimista en IDs)
      final newIds = Set<String>.from(state.productIds)..add(productId);
      state = state.copyWith(productIds: newIds);

      await _repo.addFavorite(productId);

      // Cargar el producto completo para la lista
      try {
        final product = await _repo.getProductById(productId);
        if (product != null && mounted) {
          state = state.copyWith(
            products: [product, ...state.products],
          );
        }
      } catch (_) {
        // Producto no encontrado — seguimos solo con el ID
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Provider del repositorio de favoritos.
final favoritesRepositoryProvider = Provider<FavoritesRepositoryImpl>((ref) {
  return FavoritesRepositoryImpl(
    dataSource: FavoritesFirestoreDataSource(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(firebaseAuthProvider),
    ),
  );
});

/// Provider global de favoritos.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.read(favoritesRepositoryProvider));
});

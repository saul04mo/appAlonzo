import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../../catalog/data/models/product_model.dart';

/// Data source que interactúa directamente con Firestore para favoritos.
///
/// Colección: users/{uid}/favorites/{productId}
class FavoritesFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoritesFirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Obtiene los IDs de favoritos y luego los productos completos.
  /// Carga los documentos en lotes de 10 por la limitación de whereIn.
  Future<List<ProductEntity>> getFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    final ids = snapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];

    final products = <ProductEntity>[];
    for (var i = 0; i < ids.length; i += 10) {
      final batch = ids.sublist(
        i,
        i + 10 > ids.length ? ids.length : i + 10,
      );
      final productDocs = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in productDocs.docs) {
        products.add(ProductModel.fromFirestore(doc));
      }
    }

    return products;
  }

  /// Agrega un producto a favoritos con timestamp de servidor.
  Future<void> addFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  /// Elimina un producto de favoritos.
  Future<void> removeFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  /// Carga un producto individual por ID.
  Future<ProductEntity?> getProductById(String productId) async {
    final doc =
        await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }
}

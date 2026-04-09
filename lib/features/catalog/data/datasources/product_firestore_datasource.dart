import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/product_model.dart';
import '../../domain/entities/product_entity.dart';

/// Data source que interactúa directamente con Firestore.
///
/// Encapsula todas las queries a la colección `products`.
class ProductFirestoreDataSource {
  final FirebaseFirestore _firestore;

  ProductFirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.products);

  /// Stream reactivo: escucha cambios en productos de un género.
  Stream<List<ProductEntity>> watchByGender(String gender) {
    return _collection
        .where('gender', isEqualTo: gender)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .where((doc) => doc.data()['active'] != false) // Hide inactive
                .map(ProductModel.fromFirestore)
                .toList());
  }

  /// Lectura única: productos por género.
  Future<List<ProductEntity>> getByGender(String gender) async {
    final snapshot =
        await _collection.where('gender', isEqualTo: gender).get();
    return snapshot.docs
        .where((doc) => doc.data()['active'] != false) // Hide inactive
        .map(ProductModel.fromFirestore)
        .toList();
  }

  /// Lectura única: producto por ID.
  Future<ProductEntity?> getById(String productId) async {
    final doc = await _collection.doc(productId).get();
    if (!doc.exists) return null;
    if (doc.data()?['active'] == false) return null; // Hide inactive
    return ProductModel.fromFirestore(doc);
  }

  /// Lectura única: productos por categoría + género.
  Future<List<ProductEntity>> getByCategory(
      String category, String gender) async {
    final snapshot = await _collection
        .where('gender', isEqualTo: gender)
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .where((doc) => doc.data()['active'] != false) // Hide inactive
        .map(ProductModel.fromFirestore)
        .toList();
  }

  /// Búsqueda por nombre (client-side filtering por limitaciones de Firestore).
  Future<List<ProductEntity>> search(String query) async {
    final normalizedQuery = query.toLowerCase();
    final snapshot = await _collection.get();
    return snapshot.docs
        .where((doc) => doc.data()['active'] != false) // Hide inactive
        .map(ProductModel.fromFirestore)
        .where((p) => p.name.toLowerCase().contains(normalizedQuery))
        .toList();
  }
}

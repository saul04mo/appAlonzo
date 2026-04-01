import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

/// Modelo de datos para Product.
///
/// Convierte entre Firestore DocumentSnapshot ↔ ProductEntity.
/// Esta clase vive en la capa `data` y es el único punto de contacto
/// con la estructura cruda de Firestore.
class ProductModel {
  ProductModel._();

  /// Construye un [ProductEntity] desde un DocumentSnapshot de Firestore.
  static ProductEntity fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      variants: _parseVariants(data['variants']),
      offer: _parseOffer(data['offer']),
    );
  }

  /// Convierte un [ProductEntity] a Map para escribir en Firestore.
  static Map<String, dynamic> toFirestore(ProductEntity product) {
    return {
      'name': product.name,
      'category': product.category,
      'gender': product.gender,
      'imageUrl': product.imageUrl,
      'variants': product.variants
          .map((v) => {
                'barcode': v.barcode,
                'color': v.color,
                'price': v.price,
                'size': v.size,
                'stock': v.stock,
              })
          .toList(),
      if (product.offer != null)
        'offer': {'type': product.offer!.type, 'value': product.offer!.value},
    };
  }

  /// Parsea el array de variantes con manejo seguro de tipos.
  static List<ProductVariantEntity> _parseVariants(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map<ProductVariantEntity>((item) {
      final map = item as Map<String, dynamic>;
      return ProductVariantEntity(
        barcode: map['barcode'] as String?,
        color: map['color'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        size: map['size'] as String? ?? '',
        stock: (map['stock'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  /// Parsea la oferta del producto.
  static OfferEntity? _parseOffer(dynamic raw) {
    if (raw == null || raw is! Map) return null;
    final map = raw as Map<String, dynamic>;
    final value = (map['value'] as num?)?.toDouble() ?? 0;
    if (value <= 0) return null;
    return OfferEntity(
      type: map['type'] as String? ?? 'percentage',
      value: value,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';
part 'product_entity.g.dart';

/// Variante de un producto (talla + color + stock + precio).
@freezed
abstract class ProductVariantEntity with _$ProductVariantEntity {
  const factory ProductVariantEntity({
    String? barcode,
    required String color,
    required double price,
    required String size,
    required int stock,
  }) = _ProductVariantEntity;

  factory ProductVariantEntity.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantEntityFromJson(json);
}

/// Oferta aplicada a un producto desde el POS.
@freezed
abstract class OfferEntity with _$OfferEntity {
  const factory OfferEntity({
    @Default('percentage') String type, // 'percentage' | 'fixed'
    @Default(0) double value,
  }) = _OfferEntity;

  factory OfferEntity.fromJson(Map<String, dynamic> json) =>
      _$OfferEntityFromJson(json);
}

/// Entidad de dominio para un Producto.
@freezed
abstract class ProductEntity with _$ProductEntity {
  const ProductEntity._();

  const factory ProductEntity({
    @Default('') String id,
    required String name,
    required String category,
    required String gender,
    required String imageUrl,
    @Default([]) List<ProductVariantEntity> variants,
    OfferEntity? offer,
  }) = _ProductEntity;

  factory ProductEntity.fromJson(Map<String, dynamic> json) =>
      _$ProductEntityFromJson(json);

  /// Tiene oferta activa.
  bool get hasOffer => offer != null && offer!.value > 0;

  /// Calcula el precio con descuento.
  double discountedPrice(double originalPrice) {
    if (!hasOffer) return originalPrice;
    if (offer!.type == 'percentage') {
      return originalPrice - (originalPrice * offer!.value / 100);
    }
    return (originalPrice - offer!.value).clamp(0, double.infinity);
  }

  /// Precio mínimo entre todas las variantes.
  double get minPrice {
    if (variants.isEmpty) return 0;
    return variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  /// Precio mínimo con descuento aplicado.
  double get minDiscountedPrice => discountedPrice(minPrice);

  /// Precio máximo entre todas las variantes.
  double get maxPrice {
    if (variants.isEmpty) return 0;
    return variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  /// Colores únicos disponibles (excluye strings vacíos).
  List<String> get availableColors =>
      variants.map((v) => v.color).where((c) => c.isNotEmpty).toSet().toList();

  /// Tallas únicas disponibles.
  List<String> get availableSizes =>
      variants.map((v) => v.size).toSet().toList();

  /// Si el producto tiene variantes con color definido.
  bool get hasColorVariants => availableColors.isNotEmpty;

  /// Verifica si hay stock para una talla.
  bool hasStock(String size, [String? color]) {
    return variants.any(
      (v) =>
          v.size == size &&
          (color == null || color.isEmpty || v.color == color) &&
          v.stock > 0,
    );
  }

  /// Obtiene la variante específica para talla + color.
  ProductVariantEntity? getVariant(String size, [String? color]) {
    try {
      return variants.firstWhere(
        (v) =>
            v.size == size &&
            (color == null || color.isEmpty || v.color == color),
      );
    } catch (_) {
      return null;
    }
  }
}

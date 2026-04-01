import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_entity.freezed.dart';
part 'cart_entity.g.dart';

/// Elemento individual del carrito de compras.
@freezed
abstract class CartItemEntity with _$CartItemEntity {
  const CartItemEntity._();

  const factory CartItemEntity({
    required String productId,
    required String productName,
    required String imageUrl,
    required String selectedSize,
    required String selectedColor,
    required double price,
    @Default(1) int quantity,
    String? barcode,
    @Default('') String offerType,   // 'percentage' | 'fixed' | ''
    @Default(0) double offerValue,   // discount value
  }) = _CartItemEntity;

  factory CartItemEntity.fromJson(Map<String, dynamic> json) =>
      _$CartItemEntityFromJson(json);

  /// Precio unitario con descuento aplicado.
  double get discountedPrice {
    if (offerValue <= 0 || offerType.isEmpty) return price;
    if (offerType == 'percentage') return price - (price * offerValue / 100);
    return (price - offerValue).clamp(0, double.infinity);
  }

  /// Si tiene oferta activa.
  bool get hasOffer => offerValue > 0 && offerType.isNotEmpty;

  /// Subtotal de este item (con descuento).
  double get subtotal => discountedPrice * quantity;

  /// Ahorro total de este item.
  double get totalSaved => (price - discountedPrice) * quantity;

  /// ID único del item en el carrito (producto + variante).
  String get cartItemId => '${productId}_${selectedSize}_$selectedColor';
}

/// Estado global del carrito.
@freezed
abstract class CartState with _$CartState {
  const CartState._();

  const factory CartState({
    @Default([]) List<CartItemEntity> items,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _CartState;

  /// Total del carrito (con descuentos aplicados).
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total sin descuentos.
  double get totalWithoutDiscounts => items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  /// Ahorro total por ofertas.
  double get totalSaved => items.fold(0, (sum, item) => sum + item.totalSaved);

  /// Cantidad total de artículos.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Verifica si el carrito está vacío.
  bool get isEmpty => items.isEmpty;
}

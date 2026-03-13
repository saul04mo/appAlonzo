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
  }) = _CartItemEntity;

  factory CartItemEntity.fromJson(Map<String, dynamic> json) =>
      _$CartItemEntityFromJson(json);

  /// Subtotal de este item.
  double get subtotal => price * quantity;

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

  /// Total del carrito.
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Cantidad total de artículos.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Verifica si el carrito está vacío.
  bool get isEmpty => items.isEmpty;
}

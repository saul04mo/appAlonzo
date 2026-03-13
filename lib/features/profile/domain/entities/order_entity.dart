import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../cart/domain/entities/cart_entity.dart';

part 'order_entity.freezed.dart';
part 'order_entity.g.dart';

/// Estado de una orden.
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Entidad de una Orden.
@freezed
abstract class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    @Default('') String id,
    required String userId,
    required List<CartItemEntity> items,
    required double totalAmount,
    @Default(OrderStatus.pending) OrderStatus status,
    required Map<String, dynamic> shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderEntity;

  factory OrderEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderEntityFromJson(json);
}

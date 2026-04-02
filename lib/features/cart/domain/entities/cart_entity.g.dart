// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemEntity _$CartItemEntityFromJson(Map<String, dynamic> json) =>
    _CartItemEntity(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      imageUrl: json['imageUrl'] as String,
      selectedSize: json['selectedSize'] as String,
      selectedColor: json['selectedColor'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      barcode: json['barcode'] as String?,
      offerType: json['offerType'] as String? ?? '',
      offerValue: (json['offerValue'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$CartItemEntityToJson(_CartItemEntity instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'imageUrl': instance.imageUrl,
      'selectedSize': instance.selectedSize,
      'selectedColor': instance.selectedColor,
      'price': instance.price,
      'quantity': instance.quantity,
      'barcode': instance.barcode,
      'offerType': instance.offerType,
      'offerValue': instance.offerValue,
    };

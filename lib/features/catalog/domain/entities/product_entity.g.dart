// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductVariantEntity _$ProductVariantEntityFromJson(
  Map<String, dynamic> json,
) => _ProductVariantEntity(
  barcode: json['barcode'] as String?,
  color: json['color'] as String,
  price: (json['price'] as num).toDouble(),
  size: json['size'] as String,
  stock: (json['stock'] as num).toInt(),
);

Map<String, dynamic> _$ProductVariantEntityToJson(
  _ProductVariantEntity instance,
) => <String, dynamic>{
  'barcode': instance.barcode,
  'color': instance.color,
  'price': instance.price,
  'size': instance.size,
  'stock': instance.stock,
};

_OfferEntity _$OfferEntityFromJson(Map<String, dynamic> json) => _OfferEntity(
  type: json['type'] as String? ?? 'percentage',
  value: (json['value'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$OfferEntityToJson(_OfferEntity instance) =>
    <String, dynamic>{'type': instance.type, 'value': instance.value};

_ProductEntity _$ProductEntityFromJson(Map<String, dynamic> json) =>
    _ProductEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      gender: json['gender'] as String,
      imageUrl: json['imageUrl'] as String,
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map(
                (e) => ProductVariantEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      offer: json['offer'] == null
          ? null
          : OfferEntity.fromJson(json['offer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductEntityToJson(_ProductEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'gender': instance.gender,
      'imageUrl': instance.imageUrl,
      'variants': instance.variants,
      'offer': instance.offer,
    };

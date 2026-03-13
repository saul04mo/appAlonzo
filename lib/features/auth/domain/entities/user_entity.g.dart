// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddressEntity _$AddressEntityFromJson(Map<String, dynamic> json) =>
    _AddressEntity(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$AddressEntityToJson(_AddressEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'country': instance.country,
      'phone': instance.phone,
      'isDefault': instance.isDefault,
    };

_UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => _UserEntity(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String? ?? '',
  photoUrl: json['photoUrl'] as String? ?? '',
  loyaltyTier:
      $enumDecodeNullable(_$LoyaltyTierEnumMap, json['loyaltyTier']) ??
      LoyaltyTier.bronze,
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
  wishlist:
      (json['wishlist'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  addresses:
      (json['addresses'] as List<dynamic>?)
          ?.map((e) => AddressEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserEntityToJson(_UserEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'loyaltyTier': _$LoyaltyTierEnumMap[instance.loyaltyTier]!,
      'loyaltyPoints': instance.loyaltyPoints,
      'wishlist': instance.wishlist,
      'addresses': instance.addresses,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$LoyaltyTierEnumMap = {
  LoyaltyTier.bronze: 'bronze',
  LoyaltyTier.silver: 'silver',
  LoyaltyTier.gold: 'gold',
  LoyaltyTier.platinum: 'platinum',
};

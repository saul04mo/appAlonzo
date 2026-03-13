import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

/// Nivel de lealtad del usuario.
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum;

  String get displayName {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
    }
  }
}

/// Dirección de envío del usuario.
@freezed
abstract class AddressEntity with _$AddressEntity {
  const factory AddressEntity({
    @Default('') String id,
    required String fullName,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    String? phone,
    @Default(false) bool isDefault,
  }) = _AddressEntity;

  factory AddressEntity.fromJson(Map<String, dynamic> json) =>
      _$AddressEntityFromJson(json);
}

/// Entidad de usuario completa.
@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    required String email,
    @Default('') String displayName,
    @Default('') String photoUrl,
    @Default(LoyaltyTier.bronze) LoyaltyTier loyaltyTier,
    @Default(0) int loyaltyPoints,
    @Default([]) List<String> wishlist,
    @Default([]) List<AddressEntity> addresses,
    DateTime? createdAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}

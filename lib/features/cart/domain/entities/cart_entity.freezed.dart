// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartItemEntity {

 String get productId; String get productName; String get imageUrl; String get selectedSize; String get selectedColor; double get price; int get quantity; String? get barcode; String get offerType;// 'percentage' | 'fixed' | ''
 double get offerValue;
/// Create a copy of CartItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemEntityCopyWith<CartItemEntity> get copyWith => _$CartItemEntityCopyWithImpl<CartItemEntity>(this as CartItemEntity, _$identity);

  /// Serializes this CartItemEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemEntity&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.selectedSize, selectedSize) || other.selectedSize == selectedSize)&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.offerType, offerType) || other.offerType == offerType)&&(identical(other.offerValue, offerValue) || other.offerValue == offerValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,imageUrl,selectedSize,selectedColor,price,quantity,barcode,offerType,offerValue);

@override
String toString() {
  return 'CartItemEntity(productId: $productId, productName: $productName, imageUrl: $imageUrl, selectedSize: $selectedSize, selectedColor: $selectedColor, price: $price, quantity: $quantity, barcode: $barcode, offerType: $offerType, offerValue: $offerValue)';
}


}

/// @nodoc
abstract mixin class $CartItemEntityCopyWith<$Res>  {
  factory $CartItemEntityCopyWith(CartItemEntity value, $Res Function(CartItemEntity) _then) = _$CartItemEntityCopyWithImpl;
@useResult
$Res call({
 String productId, String productName, String imageUrl, String selectedSize, String selectedColor, double price, int quantity, String? barcode, String offerType, double offerValue
});




}
/// @nodoc
class _$CartItemEntityCopyWithImpl<$Res>
    implements $CartItemEntityCopyWith<$Res> {
  _$CartItemEntityCopyWithImpl(this._self, this._then);

  final CartItemEntity _self;
  final $Res Function(CartItemEntity) _then;

/// Create a copy of CartItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? imageUrl = null,Object? selectedSize = null,Object? selectedColor = null,Object? price = null,Object? quantity = null,Object? barcode = freezed,Object? offerType = null,Object? offerValue = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,selectedSize: null == selectedSize ? _self.selectedSize : selectedSize // ignore: cast_nullable_to_non_nullable
as String,selectedColor: null == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,offerType: null == offerType ? _self.offerType : offerType // ignore: cast_nullable_to_non_nullable
as String,offerValue: null == offerValue ? _self.offerValue : offerValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItemEntity].
extension CartItemEntityPatterns on CartItemEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _CartItemEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CartItemEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String productName,  String imageUrl,  String selectedSize,  String selectedColor,  double price,  int quantity,  String? barcode,  String offerType,  double offerValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemEntity() when $default != null:
return $default(_that.productId,_that.productName,_that.imageUrl,_that.selectedSize,_that.selectedColor,_that.price,_that.quantity,_that.barcode,_that.offerType,_that.offerValue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String productName,  String imageUrl,  String selectedSize,  String selectedColor,  double price,  int quantity,  String? barcode,  String offerType,  double offerValue)  $default,) {final _that = this;
switch (_that) {
case _CartItemEntity():
return $default(_that.productId,_that.productName,_that.imageUrl,_that.selectedSize,_that.selectedColor,_that.price,_that.quantity,_that.barcode,_that.offerType,_that.offerValue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String productName,  String imageUrl,  String selectedSize,  String selectedColor,  double price,  int quantity,  String? barcode,  String offerType,  double offerValue)?  $default,) {final _that = this;
switch (_that) {
case _CartItemEntity() when $default != null:
return $default(_that.productId,_that.productName,_that.imageUrl,_that.selectedSize,_that.selectedColor,_that.price,_that.quantity,_that.barcode,_that.offerType,_that.offerValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemEntity extends CartItemEntity {
  const _CartItemEntity({required this.productId, required this.productName, required this.imageUrl, required this.selectedSize, required this.selectedColor, required this.price, this.quantity = 1, this.barcode, this.offerType = '', this.offerValue = 0}): super._();
  factory _CartItemEntity.fromJson(Map<String, dynamic> json) => _$CartItemEntityFromJson(json);

@override final  String productId;
@override final  String productName;
@override final  String imageUrl;
@override final  String selectedSize;
@override final  String selectedColor;
@override final  double price;
@override@JsonKey() final  int quantity;
@override final  String? barcode;
@override@JsonKey() final  String offerType;
// 'percentage' | 'fixed' | ''
@override@JsonKey() final  double offerValue;

/// Create a copy of CartItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemEntityCopyWith<_CartItemEntity> get copyWith => __$CartItemEntityCopyWithImpl<_CartItemEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemEntity&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.selectedSize, selectedSize) || other.selectedSize == selectedSize)&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.offerType, offerType) || other.offerType == offerType)&&(identical(other.offerValue, offerValue) || other.offerValue == offerValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,imageUrl,selectedSize,selectedColor,price,quantity,barcode,offerType,offerValue);

@override
String toString() {
  return 'CartItemEntity(productId: $productId, productName: $productName, imageUrl: $imageUrl, selectedSize: $selectedSize, selectedColor: $selectedColor, price: $price, quantity: $quantity, barcode: $barcode, offerType: $offerType, offerValue: $offerValue)';
}


}

/// @nodoc
abstract mixin class _$CartItemEntityCopyWith<$Res> implements $CartItemEntityCopyWith<$Res> {
  factory _$CartItemEntityCopyWith(_CartItemEntity value, $Res Function(_CartItemEntity) _then) = __$CartItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String productId, String productName, String imageUrl, String selectedSize, String selectedColor, double price, int quantity, String? barcode, String offerType, double offerValue
});




}
/// @nodoc
class __$CartItemEntityCopyWithImpl<$Res>
    implements _$CartItemEntityCopyWith<$Res> {
  __$CartItemEntityCopyWithImpl(this._self, this._then);

  final _CartItemEntity _self;
  final $Res Function(_CartItemEntity) _then;

/// Create a copy of CartItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? imageUrl = null,Object? selectedSize = null,Object? selectedColor = null,Object? price = null,Object? quantity = null,Object? barcode = freezed,Object? offerType = null,Object? offerValue = null,}) {
  return _then(_CartItemEntity(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,selectedSize: null == selectedSize ? _self.selectedSize : selectedSize // ignore: cast_nullable_to_non_nullable
as String,selectedColor: null == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,offerType: null == offerType ? _self.offerType : offerType // ignore: cast_nullable_to_non_nullable
as String,offerValue: null == offerValue ? _self.offerValue : offerValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$CartState {

 List<CartItemEntity> get items; bool get isLoading; String? get errorMessage;
/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartStateCopyWith<CartState> get copyWith => _$CartStateCopyWithImpl<CartState>(this as CartState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),isLoading,errorMessage);

@override
String toString() {
  return 'CartState(items: $items, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $CartStateCopyWith<$Res>  {
  factory $CartStateCopyWith(CartState value, $Res Function(CartState) _then) = _$CartStateCopyWithImpl;
@useResult
$Res call({
 List<CartItemEntity> items, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$CartStateCopyWithImpl<$Res>
    implements $CartStateCopyWith<$Res> {
  _$CartStateCopyWithImpl(this._self, this._then);

  final CartState _self;
  final $Res Function(CartState) _then;

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartState].
extension CartStatePatterns on CartState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartState value)  $default,){
final _that = this;
switch (_that) {
case _CartState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartState value)?  $default,){
final _that = this;
switch (_that) {
case _CartState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CartItemEntity> items,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartState() when $default != null:
return $default(_that.items,_that.isLoading,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CartItemEntity> items,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _CartState():
return $default(_that.items,_that.isLoading,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CartItemEntity> items,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _CartState() when $default != null:
return $default(_that.items,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _CartState extends CartState {
  const _CartState({final  List<CartItemEntity> items = const [], this.isLoading = false, this.errorMessage}): _items = items,super._();
  

 final  List<CartItemEntity> _items;
@override@JsonKey() List<CartItemEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartStateCopyWith<_CartState> get copyWith => __$CartStateCopyWithImpl<_CartState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isLoading,errorMessage);

@override
String toString() {
  return 'CartState(items: $items, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$CartStateCopyWith<$Res> implements $CartStateCopyWith<$Res> {
  factory _$CartStateCopyWith(_CartState value, $Res Function(_CartState) _then) = __$CartStateCopyWithImpl;
@override @useResult
$Res call({
 List<CartItemEntity> items, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$CartStateCopyWithImpl<$Res>
    implements _$CartStateCopyWith<$Res> {
  __$CartStateCopyWithImpl(this._self, this._then);

  final _CartState _self;
  final $Res Function(_CartState) _then;

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_CartState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

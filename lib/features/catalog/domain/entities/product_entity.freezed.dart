// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductVariantEntity {

 String? get barcode; String get color; double get price; String get size; int get stock;
/// Create a copy of ProductVariantEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductVariantEntityCopyWith<ProductVariantEntity> get copyWith => _$ProductVariantEntityCopyWithImpl<ProductVariantEntity>(this as ProductVariantEntity, _$identity);

  /// Serializes this ProductVariantEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductVariantEntity&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.color, color) || other.color == color)&&(identical(other.price, price) || other.price == price)&&(identical(other.size, size) || other.size == size)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,barcode,color,price,size,stock);

@override
String toString() {
  return 'ProductVariantEntity(barcode: $barcode, color: $color, price: $price, size: $size, stock: $stock)';
}


}

/// @nodoc
abstract mixin class $ProductVariantEntityCopyWith<$Res>  {
  factory $ProductVariantEntityCopyWith(ProductVariantEntity value, $Res Function(ProductVariantEntity) _then) = _$ProductVariantEntityCopyWithImpl;
@useResult
$Res call({
 String? barcode, String color, double price, String size, int stock
});




}
/// @nodoc
class _$ProductVariantEntityCopyWithImpl<$Res>
    implements $ProductVariantEntityCopyWith<$Res> {
  _$ProductVariantEntityCopyWithImpl(this._self, this._then);

  final ProductVariantEntity _self;
  final $Res Function(ProductVariantEntity) _then;

/// Create a copy of ProductVariantEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = freezed,Object? color = null,Object? price = null,Object? size = null,Object? stock = null,}) {
  return _then(_self.copyWith(
barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductVariantEntity].
extension ProductVariantEntityPatterns on ProductVariantEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductVariantEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductVariantEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductVariantEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProductVariantEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductVariantEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProductVariantEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? barcode,  String color,  double price,  String size,  int stock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductVariantEntity() when $default != null:
return $default(_that.barcode,_that.color,_that.price,_that.size,_that.stock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? barcode,  String color,  double price,  String size,  int stock)  $default,) {final _that = this;
switch (_that) {
case _ProductVariantEntity():
return $default(_that.barcode,_that.color,_that.price,_that.size,_that.stock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? barcode,  String color,  double price,  String size,  int stock)?  $default,) {final _that = this;
switch (_that) {
case _ProductVariantEntity() when $default != null:
return $default(_that.barcode,_that.color,_that.price,_that.size,_that.stock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductVariantEntity implements ProductVariantEntity {
  const _ProductVariantEntity({this.barcode, required this.color, required this.price, required this.size, required this.stock});
  factory _ProductVariantEntity.fromJson(Map<String, dynamic> json) => _$ProductVariantEntityFromJson(json);

@override final  String? barcode;
@override final  String color;
@override final  double price;
@override final  String size;
@override final  int stock;

/// Create a copy of ProductVariantEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductVariantEntityCopyWith<_ProductVariantEntity> get copyWith => __$ProductVariantEntityCopyWithImpl<_ProductVariantEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductVariantEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductVariantEntity&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.color, color) || other.color == color)&&(identical(other.price, price) || other.price == price)&&(identical(other.size, size) || other.size == size)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,barcode,color,price,size,stock);

@override
String toString() {
  return 'ProductVariantEntity(barcode: $barcode, color: $color, price: $price, size: $size, stock: $stock)';
}


}

/// @nodoc
abstract mixin class _$ProductVariantEntityCopyWith<$Res> implements $ProductVariantEntityCopyWith<$Res> {
  factory _$ProductVariantEntityCopyWith(_ProductVariantEntity value, $Res Function(_ProductVariantEntity) _then) = __$ProductVariantEntityCopyWithImpl;
@override @useResult
$Res call({
 String? barcode, String color, double price, String size, int stock
});




}
/// @nodoc
class __$ProductVariantEntityCopyWithImpl<$Res>
    implements _$ProductVariantEntityCopyWith<$Res> {
  __$ProductVariantEntityCopyWithImpl(this._self, this._then);

  final _ProductVariantEntity _self;
  final $Res Function(_ProductVariantEntity) _then;

/// Create a copy of ProductVariantEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = freezed,Object? color = null,Object? price = null,Object? size = null,Object? stock = null,}) {
  return _then(_ProductVariantEntity(
barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OfferEntity {

 String get type;// 'percentage' | 'fixed'
 double get value;
/// Create a copy of OfferEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferEntityCopyWith<OfferEntity> get copyWith => _$OfferEntityCopyWithImpl<OfferEntity>(this as OfferEntity, _$identity);

  /// Serializes this OfferEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value);

@override
String toString() {
  return 'OfferEntity(type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class $OfferEntityCopyWith<$Res>  {
  factory $OfferEntityCopyWith(OfferEntity value, $Res Function(OfferEntity) _then) = _$OfferEntityCopyWithImpl;
@useResult
$Res call({
 String type, double value
});




}
/// @nodoc
class _$OfferEntityCopyWithImpl<$Res>
    implements $OfferEntityCopyWith<$Res> {
  _$OfferEntityCopyWithImpl(this._self, this._then);

  final OfferEntity _self;
  final $Res Function(OfferEntity) _then;

/// Create a copy of OfferEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? value = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferEntity].
extension OfferEntityPatterns on OfferEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferEntity value)  $default,){
final _that = this;
switch (_that) {
case _OfferEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferEntity value)?  $default,){
final _that = this;
switch (_that) {
case _OfferEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferEntity() when $default != null:
return $default(_that.type,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  double value)  $default,) {final _that = this;
switch (_that) {
case _OfferEntity():
return $default(_that.type,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  double value)?  $default,) {final _that = this;
switch (_that) {
case _OfferEntity() when $default != null:
return $default(_that.type,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferEntity implements OfferEntity {
  const _OfferEntity({this.type = 'percentage', this.value = 0});
  factory _OfferEntity.fromJson(Map<String, dynamic> json) => _$OfferEntityFromJson(json);

@override@JsonKey() final  String type;
// 'percentage' | 'fixed'
@override@JsonKey() final  double value;

/// Create a copy of OfferEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferEntityCopyWith<_OfferEntity> get copyWith => __$OfferEntityCopyWithImpl<_OfferEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value);

@override
String toString() {
  return 'OfferEntity(type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class _$OfferEntityCopyWith<$Res> implements $OfferEntityCopyWith<$Res> {
  factory _$OfferEntityCopyWith(_OfferEntity value, $Res Function(_OfferEntity) _then) = __$OfferEntityCopyWithImpl;
@override @useResult
$Res call({
 String type, double value
});




}
/// @nodoc
class __$OfferEntityCopyWithImpl<$Res>
    implements _$OfferEntityCopyWith<$Res> {
  __$OfferEntityCopyWithImpl(this._self, this._then);

  final _OfferEntity _self;
  final $Res Function(_OfferEntity) _then;

/// Create a copy of OfferEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = null,}) {
  return _then(_OfferEntity(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ProductEntity {

 String get id; String get name; String get category; String get gender; String get imageUrl; List<ProductVariantEntity> get variants; OfferEntity? get offer;
/// Create a copy of ProductEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductEntityCopyWith<ProductEntity> get copyWith => _$ProductEntityCopyWithImpl<ProductEntity>(this as ProductEntity, _$identity);

  /// Serializes this ProductEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.variants, variants)&&(identical(other.offer, offer) || other.offer == offer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,gender,imageUrl,const DeepCollectionEquality().hash(variants),offer);

@override
String toString() {
  return 'ProductEntity(id: $id, name: $name, category: $category, gender: $gender, imageUrl: $imageUrl, variants: $variants, offer: $offer)';
}


}

/// @nodoc
abstract mixin class $ProductEntityCopyWith<$Res>  {
  factory $ProductEntityCopyWith(ProductEntity value, $Res Function(ProductEntity) _then) = _$ProductEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, String gender, String imageUrl, List<ProductVariantEntity> variants, OfferEntity? offer
});


$OfferEntityCopyWith<$Res>? get offer;

}
/// @nodoc
class _$ProductEntityCopyWithImpl<$Res>
    implements $ProductEntityCopyWith<$Res> {
  _$ProductEntityCopyWithImpl(this._self, this._then);

  final ProductEntity _self;
  final $Res Function(ProductEntity) _then;

/// Create a copy of ProductEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? gender = null,Object? imageUrl = null,Object? variants = null,Object? offer = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<ProductVariantEntity>,offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferEntity?,
  ));
}
/// Create a copy of ProductEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferEntityCopyWith<$Res>? get offer {
    if (_self.offer == null) {
    return null;
  }

  return $OfferEntityCopyWith<$Res>(_self.offer!, (value) {
    return _then(_self.copyWith(offer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductEntity].
extension ProductEntityPatterns on ProductEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProductEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProductEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String gender,  String imageUrl,  List<ProductVariantEntity> variants,  OfferEntity? offer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductEntity() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.gender,_that.imageUrl,_that.variants,_that.offer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String gender,  String imageUrl,  List<ProductVariantEntity> variants,  OfferEntity? offer)  $default,) {final _that = this;
switch (_that) {
case _ProductEntity():
return $default(_that.id,_that.name,_that.category,_that.gender,_that.imageUrl,_that.variants,_that.offer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  String gender,  String imageUrl,  List<ProductVariantEntity> variants,  OfferEntity? offer)?  $default,) {final _that = this;
switch (_that) {
case _ProductEntity() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.gender,_that.imageUrl,_that.variants,_that.offer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductEntity extends ProductEntity {
  const _ProductEntity({this.id = '', required this.name, required this.category, required this.gender, required this.imageUrl, final  List<ProductVariantEntity> variants = const [], this.offer}): _variants = variants,super._();
  factory _ProductEntity.fromJson(Map<String, dynamic> json) => _$ProductEntityFromJson(json);

@override@JsonKey() final  String id;
@override final  String name;
@override final  String category;
@override final  String gender;
@override final  String imageUrl;
 final  List<ProductVariantEntity> _variants;
@override@JsonKey() List<ProductVariantEntity> get variants {
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variants);
}

@override final  OfferEntity? offer;

/// Create a copy of ProductEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductEntityCopyWith<_ProductEntity> get copyWith => __$ProductEntityCopyWithImpl<_ProductEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._variants, _variants)&&(identical(other.offer, offer) || other.offer == offer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,gender,imageUrl,const DeepCollectionEquality().hash(_variants),offer);

@override
String toString() {
  return 'ProductEntity(id: $id, name: $name, category: $category, gender: $gender, imageUrl: $imageUrl, variants: $variants, offer: $offer)';
}


}

/// @nodoc
abstract mixin class _$ProductEntityCopyWith<$Res> implements $ProductEntityCopyWith<$Res> {
  factory _$ProductEntityCopyWith(_ProductEntity value, $Res Function(_ProductEntity) _then) = __$ProductEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, String gender, String imageUrl, List<ProductVariantEntity> variants, OfferEntity? offer
});


@override $OfferEntityCopyWith<$Res>? get offer;

}
/// @nodoc
class __$ProductEntityCopyWithImpl<$Res>
    implements _$ProductEntityCopyWith<$Res> {
  __$ProductEntityCopyWithImpl(this._self, this._then);

  final _ProductEntity _self;
  final $Res Function(_ProductEntity) _then;

/// Create a copy of ProductEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? gender = null,Object? imageUrl = null,Object? variants = null,Object? offer = freezed,}) {
  return _then(_ProductEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<ProductVariantEntity>,offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferEntity?,
  ));
}

/// Create a copy of ProductEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferEntityCopyWith<$Res>? get offer {
    if (_self.offer == null) {
    return null;
  }

  return $OfferEntityCopyWith<$Res>(_self.offer!, (value) {
    return _then(_self.copyWith(offer: value));
  });
}
}

// dart format on

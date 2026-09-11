// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compression_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageResizeMode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageResizeMode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImageResizeMode()';
}


}

/// @nodoc
class $ImageResizeModeCopyWith<$Res>  {
$ImageResizeModeCopyWith(ImageResizeMode _, $Res Function(ImageResizeMode) __);
}


/// Adds pattern-matching-related methods to [ImageResizeMode].
extension ImageResizeModePatterns on ImageResizeMode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _None value)?  none,TResult Function( _MaxLongEdge value)?  maxLongEdge,TResult Function( _ExactSize value)?  exactSize,TResult Function( _ScalePercentage value)?  scalePercentage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _None() when none != null:
return none(_that);case _MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that);case _ExactSize() when exactSize != null:
return exactSize(_that);case _ScalePercentage() when scalePercentage != null:
return scalePercentage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _None value)  none,required TResult Function( _MaxLongEdge value)  maxLongEdge,required TResult Function( _ExactSize value)  exactSize,required TResult Function( _ScalePercentage value)  scalePercentage,}){
final _that = this;
switch (_that) {
case _None():
return none(_that);case _MaxLongEdge():
return maxLongEdge(_that);case _ExactSize():
return exactSize(_that);case _ScalePercentage():
return scalePercentage(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _None value)?  none,TResult? Function( _MaxLongEdge value)?  maxLongEdge,TResult? Function( _ExactSize value)?  exactSize,TResult? Function( _ScalePercentage value)?  scalePercentage,}){
final _that = this;
switch (_that) {
case _None() when none != null:
return none(_that);case _MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that);case _ExactSize() when exactSize != null:
return exactSize(_that);case _ScalePercentage() when scalePercentage != null:
return scalePercentage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( int value)?  maxLongEdge,TResult Function( int width,  int height,  bool keepAspectRatio)?  exactSize,TResult Function( double percentage)?  scalePercentage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _None() when none != null:
return none();case _MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that.value);case _ExactSize() when exactSize != null:
return exactSize(_that.width,_that.height,_that.keepAspectRatio);case _ScalePercentage() when scalePercentage != null:
return scalePercentage(_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( int value)  maxLongEdge,required TResult Function( int width,  int height,  bool keepAspectRatio)  exactSize,required TResult Function( double percentage)  scalePercentage,}) {final _that = this;
switch (_that) {
case _None():
return none();case _MaxLongEdge():
return maxLongEdge(_that.value);case _ExactSize():
return exactSize(_that.width,_that.height,_that.keepAspectRatio);case _ScalePercentage():
return scalePercentage(_that.percentage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( int value)?  maxLongEdge,TResult? Function( int width,  int height,  bool keepAspectRatio)?  exactSize,TResult? Function( double percentage)?  scalePercentage,}) {final _that = this;
switch (_that) {
case _None() when none != null:
return none();case _MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that.value);case _ExactSize() when exactSize != null:
return exactSize(_that.width,_that.height,_that.keepAspectRatio);case _ScalePercentage() when scalePercentage != null:
return scalePercentage(_that.percentage);case _:
  return null;

}
}

}

/// @nodoc


class _None implements ImageResizeMode {
  const _None();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _None);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ImageResizeMode.none()';
}


}




/// @nodoc


class _MaxLongEdge implements ImageResizeMode {
  const _MaxLongEdge(this.value);
  

 final  int value;

/// Create a copy of ImageResizeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaxLongEdgeCopyWith<_MaxLongEdge> get copyWith => __$MaxLongEdgeCopyWithImpl<_MaxLongEdge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaxLongEdge&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ImageResizeMode.maxLongEdge(value: $value)';
}


}

/// @nodoc
abstract mixin class _$MaxLongEdgeCopyWith<$Res> implements $ImageResizeModeCopyWith<$Res> {
  factory _$MaxLongEdgeCopyWith(_MaxLongEdge value, $Res Function(_MaxLongEdge) _then) = __$MaxLongEdgeCopyWithImpl;
@useResult
$Res call({
 int value
});




}
/// @nodoc
class __$MaxLongEdgeCopyWithImpl<$Res>
    implements _$MaxLongEdgeCopyWith<$Res> {
  __$MaxLongEdgeCopyWithImpl(this._self, this._then);

  final _MaxLongEdge _self;
  final $Res Function(_MaxLongEdge) _then;

/// Create a copy of ImageResizeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_MaxLongEdge(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ExactSize implements ImageResizeMode {
  const _ExactSize({required this.width, required this.height, this.keepAspectRatio = true});
  

 final  int width;
 final  int height;
@JsonKey() final  bool keepAspectRatio;

/// Create a copy of ImageResizeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExactSizeCopyWith<_ExactSize> get copyWith => __$ExactSizeCopyWithImpl<_ExactSize>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExactSize&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.keepAspectRatio, keepAspectRatio) || other.keepAspectRatio == keepAspectRatio));
}


@override
int get hashCode => Object.hash(runtimeType,width,height,keepAspectRatio);

@override
String toString() {
  return 'ImageResizeMode.exactSize(width: $width, height: $height, keepAspectRatio: $keepAspectRatio)';
}


}

/// @nodoc
abstract mixin class _$ExactSizeCopyWith<$Res> implements $ImageResizeModeCopyWith<$Res> {
  factory _$ExactSizeCopyWith(_ExactSize value, $Res Function(_ExactSize) _then) = __$ExactSizeCopyWithImpl;
@useResult
$Res call({
 int width, int height, bool keepAspectRatio
});




}
/// @nodoc
class __$ExactSizeCopyWithImpl<$Res>
    implements _$ExactSizeCopyWith<$Res> {
  __$ExactSizeCopyWithImpl(this._self, this._then);

  final _ExactSize _self;
  final $Res Function(_ExactSize) _then;

/// Create a copy of ImageResizeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? keepAspectRatio = null,}) {
  return _then(_ExactSize(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,keepAspectRatio: null == keepAspectRatio ? _self.keepAspectRatio : keepAspectRatio // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _ScalePercentage implements ImageResizeMode {
  const _ScalePercentage(this.percentage);
  

 final  double percentage;

/// Create a copy of ImageResizeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScalePercentageCopyWith<_ScalePercentage> get copyWith => __$ScalePercentageCopyWithImpl<_ScalePercentage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScalePercentage&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,percentage);

@override
String toString() {
  return 'ImageResizeMode.scalePercentage(percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$ScalePercentageCopyWith<$Res> implements $ImageResizeModeCopyWith<$Res> {
  factory _$ScalePercentageCopyWith(_ScalePercentage value, $Res Function(_ScalePercentage) _then) = __$ScalePercentageCopyWithImpl;
@useResult
$Res call({
 double percentage
});




}
/// @nodoc
class __$ScalePercentageCopyWithImpl<$Res>
    implements _$ScalePercentageCopyWith<$Res> {
  __$ScalePercentageCopyWithImpl(this._self, this._then);

  final _ScalePercentage _self;
  final $Res Function(_ScalePercentage) _then;

/// Create a copy of ImageResizeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? percentage = null,}) {
  return _then(_ScalePercentage(
null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

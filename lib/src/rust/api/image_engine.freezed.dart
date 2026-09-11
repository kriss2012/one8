// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResizeMode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizeMode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ResizeMode()';
}


}

/// @nodoc
class $ResizeModeCopyWith<$Res>  {
$ResizeModeCopyWith(ResizeMode _, $Res Function(ResizeMode) __);
}


/// Adds pattern-matching-related methods to [ResizeMode].
extension ResizeModePatterns on ResizeMode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ResizeMode_None value)?  none,TResult Function( ResizeMode_MaxLongEdge value)?  maxLongEdge,TResult Function( ResizeMode_ExactSize value)?  exactSize,TResult Function( ResizeMode_ScalePercentage value)?  scalePercentage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ResizeMode_None() when none != null:
return none(_that);case ResizeMode_MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that);case ResizeMode_ExactSize() when exactSize != null:
return exactSize(_that);case ResizeMode_ScalePercentage() when scalePercentage != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ResizeMode_None value)  none,required TResult Function( ResizeMode_MaxLongEdge value)  maxLongEdge,required TResult Function( ResizeMode_ExactSize value)  exactSize,required TResult Function( ResizeMode_ScalePercentage value)  scalePercentage,}){
final _that = this;
switch (_that) {
case ResizeMode_None():
return none(_that);case ResizeMode_MaxLongEdge():
return maxLongEdge(_that);case ResizeMode_ExactSize():
return exactSize(_that);case ResizeMode_ScalePercentage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ResizeMode_None value)?  none,TResult? Function( ResizeMode_MaxLongEdge value)?  maxLongEdge,TResult? Function( ResizeMode_ExactSize value)?  exactSize,TResult? Function( ResizeMode_ScalePercentage value)?  scalePercentage,}){
final _that = this;
switch (_that) {
case ResizeMode_None() when none != null:
return none(_that);case ResizeMode_MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that);case ResizeMode_ExactSize() when exactSize != null:
return exactSize(_that);case ResizeMode_ScalePercentage() when scalePercentage != null:
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
case ResizeMode_None() when none != null:
return none();case ResizeMode_MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that.value);case ResizeMode_ExactSize() when exactSize != null:
return exactSize(_that.width,_that.height,_that.keepAspectRatio);case ResizeMode_ScalePercentage() when scalePercentage != null:
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
case ResizeMode_None():
return none();case ResizeMode_MaxLongEdge():
return maxLongEdge(_that.value);case ResizeMode_ExactSize():
return exactSize(_that.width,_that.height,_that.keepAspectRatio);case ResizeMode_ScalePercentage():
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
case ResizeMode_None() when none != null:
return none();case ResizeMode_MaxLongEdge() when maxLongEdge != null:
return maxLongEdge(_that.value);case ResizeMode_ExactSize() when exactSize != null:
return exactSize(_that.width,_that.height,_that.keepAspectRatio);case ResizeMode_ScalePercentage() when scalePercentage != null:
return scalePercentage(_that.percentage);case _:
  return null;

}
}

}

/// @nodoc


class ResizeMode_None extends ResizeMode {
  const ResizeMode_None(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizeMode_None);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ResizeMode.none()';
}


}




/// @nodoc


class ResizeMode_MaxLongEdge extends ResizeMode {
  const ResizeMode_MaxLongEdge({required this.value}): super._();
  

 final  int value;

/// Create a copy of ResizeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResizeMode_MaxLongEdgeCopyWith<ResizeMode_MaxLongEdge> get copyWith => _$ResizeMode_MaxLongEdgeCopyWithImpl<ResizeMode_MaxLongEdge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizeMode_MaxLongEdge&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ResizeMode.maxLongEdge(value: $value)';
}


}

/// @nodoc
abstract mixin class $ResizeMode_MaxLongEdgeCopyWith<$Res> implements $ResizeModeCopyWith<$Res> {
  factory $ResizeMode_MaxLongEdgeCopyWith(ResizeMode_MaxLongEdge value, $Res Function(ResizeMode_MaxLongEdge) _then) = _$ResizeMode_MaxLongEdgeCopyWithImpl;
@useResult
$Res call({
 int value
});




}
/// @nodoc
class _$ResizeMode_MaxLongEdgeCopyWithImpl<$Res>
    implements $ResizeMode_MaxLongEdgeCopyWith<$Res> {
  _$ResizeMode_MaxLongEdgeCopyWithImpl(this._self, this._then);

  final ResizeMode_MaxLongEdge _self;
  final $Res Function(ResizeMode_MaxLongEdge) _then;

/// Create a copy of ResizeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(ResizeMode_MaxLongEdge(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ResizeMode_ExactSize extends ResizeMode {
  const ResizeMode_ExactSize({required this.width, required this.height, required this.keepAspectRatio}): super._();
  

 final  int width;
 final  int height;
 final  bool keepAspectRatio;

/// Create a copy of ResizeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResizeMode_ExactSizeCopyWith<ResizeMode_ExactSize> get copyWith => _$ResizeMode_ExactSizeCopyWithImpl<ResizeMode_ExactSize>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizeMode_ExactSize&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.keepAspectRatio, keepAspectRatio) || other.keepAspectRatio == keepAspectRatio));
}


@override
int get hashCode => Object.hash(runtimeType,width,height,keepAspectRatio);

@override
String toString() {
  return 'ResizeMode.exactSize(width: $width, height: $height, keepAspectRatio: $keepAspectRatio)';
}


}

/// @nodoc
abstract mixin class $ResizeMode_ExactSizeCopyWith<$Res> implements $ResizeModeCopyWith<$Res> {
  factory $ResizeMode_ExactSizeCopyWith(ResizeMode_ExactSize value, $Res Function(ResizeMode_ExactSize) _then) = _$ResizeMode_ExactSizeCopyWithImpl;
@useResult
$Res call({
 int width, int height, bool keepAspectRatio
});




}
/// @nodoc
class _$ResizeMode_ExactSizeCopyWithImpl<$Res>
    implements $ResizeMode_ExactSizeCopyWith<$Res> {
  _$ResizeMode_ExactSizeCopyWithImpl(this._self, this._then);

  final ResizeMode_ExactSize _self;
  final $Res Function(ResizeMode_ExactSize) _then;

/// Create a copy of ResizeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? keepAspectRatio = null,}) {
  return _then(ResizeMode_ExactSize(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,keepAspectRatio: null == keepAspectRatio ? _self.keepAspectRatio : keepAspectRatio // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ResizeMode_ScalePercentage extends ResizeMode {
  const ResizeMode_ScalePercentage({required this.percentage}): super._();
  

 final  double percentage;

/// Create a copy of ResizeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResizeMode_ScalePercentageCopyWith<ResizeMode_ScalePercentage> get copyWith => _$ResizeMode_ScalePercentageCopyWithImpl<ResizeMode_ScalePercentage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizeMode_ScalePercentage&&(identical(other.percentage, percentage) || other.percentage == percentage));
}


@override
int get hashCode => Object.hash(runtimeType,percentage);

@override
String toString() {
  return 'ResizeMode.scalePercentage(percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $ResizeMode_ScalePercentageCopyWith<$Res> implements $ResizeModeCopyWith<$Res> {
  factory $ResizeMode_ScalePercentageCopyWith(ResizeMode_ScalePercentage value, $Res Function(ResizeMode_ScalePercentage) _then) = _$ResizeMode_ScalePercentageCopyWithImpl;
@useResult
$Res call({
 double percentage
});




}
/// @nodoc
class _$ResizeMode_ScalePercentageCopyWithImpl<$Res>
    implements $ResizeMode_ScalePercentageCopyWith<$Res> {
  _$ResizeMode_ScalePercentageCopyWithImpl(this._self, this._then);

  final ResizeMode_ScalePercentage _self;
  final $Res Function(ResizeMode_ScalePercentage) _then;

/// Create a copy of ResizeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? percentage = null,}) {
  return _then(ResizeMode_ScalePercentage(
percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compression_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompressionHistoryItem {

 int get id; String get originalPath; String get outputPath; String get outputFileName; int get originalBytes; int get compressedBytes; DateTime get timestamp; String get format;
/// Create a copy of CompressionHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompressionHistoryItemCopyWith<CompressionHistoryItem> get copyWith => _$CompressionHistoryItemCopyWithImpl<CompressionHistoryItem>(this as CompressionHistoryItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompressionHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.originalPath, originalPath) || other.originalPath == originalPath)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.outputFileName, outputFileName) || other.outputFileName == outputFileName)&&(identical(other.originalBytes, originalBytes) || other.originalBytes == originalBytes)&&(identical(other.compressedBytes, compressedBytes) || other.compressedBytes == compressedBytes)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,id,originalPath,outputPath,outputFileName,originalBytes,compressedBytes,timestamp,format);

@override
String toString() {
  return 'CompressionHistoryItem(id: $id, originalPath: $originalPath, outputPath: $outputPath, outputFileName: $outputFileName, originalBytes: $originalBytes, compressedBytes: $compressedBytes, timestamp: $timestamp, format: $format)';
}


}

/// @nodoc
abstract mixin class $CompressionHistoryItemCopyWith<$Res>  {
  factory $CompressionHistoryItemCopyWith(CompressionHistoryItem value, $Res Function(CompressionHistoryItem) _then) = _$CompressionHistoryItemCopyWithImpl;
@useResult
$Res call({
 int id, String originalPath, String outputPath, String outputFileName, int originalBytes, int compressedBytes, DateTime timestamp, String format
});




}
/// @nodoc
class _$CompressionHistoryItemCopyWithImpl<$Res>
    implements $CompressionHistoryItemCopyWith<$Res> {
  _$CompressionHistoryItemCopyWithImpl(this._self, this._then);

  final CompressionHistoryItem _self;
  final $Res Function(CompressionHistoryItem) _then;

/// Create a copy of CompressionHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? originalPath = null,Object? outputPath = null,Object? outputFileName = null,Object? originalBytes = null,Object? compressedBytes = null,Object? timestamp = null,Object? format = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,originalPath: null == originalPath ? _self.originalPath : originalPath // ignore: cast_nullable_to_non_nullable
as String,outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,outputFileName: null == outputFileName ? _self.outputFileName : outputFileName // ignore: cast_nullable_to_non_nullable
as String,originalBytes: null == originalBytes ? _self.originalBytes : originalBytes // ignore: cast_nullable_to_non_nullable
as int,compressedBytes: null == compressedBytes ? _self.compressedBytes : compressedBytes // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompressionHistoryItem].
extension CompressionHistoryItemPatterns on CompressionHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompressionHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompressionHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompressionHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _CompressionHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompressionHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _CompressionHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String originalPath,  String outputPath,  String outputFileName,  int originalBytes,  int compressedBytes,  DateTime timestamp,  String format)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompressionHistoryItem() when $default != null:
return $default(_that.id,_that.originalPath,_that.outputPath,_that.outputFileName,_that.originalBytes,_that.compressedBytes,_that.timestamp,_that.format);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String originalPath,  String outputPath,  String outputFileName,  int originalBytes,  int compressedBytes,  DateTime timestamp,  String format)  $default,) {final _that = this;
switch (_that) {
case _CompressionHistoryItem():
return $default(_that.id,_that.originalPath,_that.outputPath,_that.outputFileName,_that.originalBytes,_that.compressedBytes,_that.timestamp,_that.format);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String originalPath,  String outputPath,  String outputFileName,  int originalBytes,  int compressedBytes,  DateTime timestamp,  String format)?  $default,) {final _that = this;
switch (_that) {
case _CompressionHistoryItem() when $default != null:
return $default(_that.id,_that.originalPath,_that.outputPath,_that.outputFileName,_that.originalBytes,_that.compressedBytes,_that.timestamp,_that.format);case _:
  return null;

}
}

}

/// @nodoc


class _CompressionHistoryItem extends CompressionHistoryItem {
  const _CompressionHistoryItem({required this.id, required this.originalPath, required this.outputPath, required this.outputFileName, required this.originalBytes, required this.compressedBytes, required this.timestamp, required this.format}): super._();
  

@override final  int id;
@override final  String originalPath;
@override final  String outputPath;
@override final  String outputFileName;
@override final  int originalBytes;
@override final  int compressedBytes;
@override final  DateTime timestamp;
@override final  String format;

/// Create a copy of CompressionHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompressionHistoryItemCopyWith<_CompressionHistoryItem> get copyWith => __$CompressionHistoryItemCopyWithImpl<_CompressionHistoryItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompressionHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.originalPath, originalPath) || other.originalPath == originalPath)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.outputFileName, outputFileName) || other.outputFileName == outputFileName)&&(identical(other.originalBytes, originalBytes) || other.originalBytes == originalBytes)&&(identical(other.compressedBytes, compressedBytes) || other.compressedBytes == compressedBytes)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,id,originalPath,outputPath,outputFileName,originalBytes,compressedBytes,timestamp,format);

@override
String toString() {
  return 'CompressionHistoryItem(id: $id, originalPath: $originalPath, outputPath: $outputPath, outputFileName: $outputFileName, originalBytes: $originalBytes, compressedBytes: $compressedBytes, timestamp: $timestamp, format: $format)';
}


}

/// @nodoc
abstract mixin class _$CompressionHistoryItemCopyWith<$Res> implements $CompressionHistoryItemCopyWith<$Res> {
  factory _$CompressionHistoryItemCopyWith(_CompressionHistoryItem value, $Res Function(_CompressionHistoryItem) _then) = __$CompressionHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String originalPath, String outputPath, String outputFileName, int originalBytes, int compressedBytes, DateTime timestamp, String format
});




}
/// @nodoc
class __$CompressionHistoryItemCopyWithImpl<$Res>
    implements _$CompressionHistoryItemCopyWith<$Res> {
  __$CompressionHistoryItemCopyWithImpl(this._self, this._then);

  final _CompressionHistoryItem _self;
  final $Res Function(_CompressionHistoryItem) _then;

/// Create a copy of CompressionHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? originalPath = null,Object? outputPath = null,Object? outputFileName = null,Object? originalBytes = null,Object? compressedBytes = null,Object? timestamp = null,Object? format = null,}) {
  return _then(_CompressionHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,originalPath: null == originalPath ? _self.originalPath : originalPath // ignore: cast_nullable_to_non_nullable
as String,outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,outputFileName: null == outputFileName ? _self.outputFileName : outputFileName // ignore: cast_nullable_to_non_nullable
as String,originalBytes: null == originalBytes ? _self.originalBytes : originalBytes // ignore: cast_nullable_to_non_nullable
as int,compressedBytes: null == compressedBytes ? _self.compressedBytes : compressedBytes // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

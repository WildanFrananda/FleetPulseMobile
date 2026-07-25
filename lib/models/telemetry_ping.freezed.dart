// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_ping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TelemetryPing {

 double get latitude; double get longitude;@JsonKey(name: 'recorded_at') DateTime get recordedAt;@JsonKey(name: 'speed_kmh') double? get speedKmh;@JsonKey(name: 'bearing_deg') double? get bearingDeg;
/// Create a copy of TelemetryPing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryPingCopyWith<TelemetryPing> get copyWith => _$TelemetryPingCopyWithImpl<TelemetryPing>(this as TelemetryPing, _$identity);

  /// Serializes this TelemetryPing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryPing&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.bearingDeg, bearingDeg) || other.bearingDeg == bearingDeg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,recordedAt,speedKmh,bearingDeg);

@override
String toString() {
  return 'TelemetryPing(latitude: $latitude, longitude: $longitude, recordedAt: $recordedAt, speedKmh: $speedKmh, bearingDeg: $bearingDeg)';
}


}

/// @nodoc
abstract mixin class $TelemetryPingCopyWith<$Res>  {
  factory $TelemetryPingCopyWith(TelemetryPing value, $Res Function(TelemetryPing) _then) = _$TelemetryPingCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude,@JsonKey(name: 'recorded_at') DateTime recordedAt,@JsonKey(name: 'speed_kmh') double? speedKmh,@JsonKey(name: 'bearing_deg') double? bearingDeg
});




}
/// @nodoc
class _$TelemetryPingCopyWithImpl<$Res>
    implements $TelemetryPingCopyWith<$Res> {
  _$TelemetryPingCopyWithImpl(this._self, this._then);

  final TelemetryPing _self;
  final $Res Function(TelemetryPing) _then;

/// Create a copy of TelemetryPing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? recordedAt = null,Object? speedKmh = freezed,Object? bearingDeg = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,bearingDeg: freezed == bearingDeg ? _self.bearingDeg : bearingDeg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TelemetryPing].
extension TelemetryPingPatterns on TelemetryPing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TelemetryPing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TelemetryPing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TelemetryPing value)  $default,){
final _that = this;
switch (_that) {
case _TelemetryPing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TelemetryPing value)?  $default,){
final _that = this;
switch (_that) {
case _TelemetryPing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude, @JsonKey(name: 'recorded_at')  DateTime recordedAt, @JsonKey(name: 'speed_kmh')  double? speedKmh, @JsonKey(name: 'bearing_deg')  double? bearingDeg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TelemetryPing() when $default != null:
return $default(_that.latitude,_that.longitude,_that.recordedAt,_that.speedKmh,_that.bearingDeg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude, @JsonKey(name: 'recorded_at')  DateTime recordedAt, @JsonKey(name: 'speed_kmh')  double? speedKmh, @JsonKey(name: 'bearing_deg')  double? bearingDeg)  $default,) {final _that = this;
switch (_that) {
case _TelemetryPing():
return $default(_that.latitude,_that.longitude,_that.recordedAt,_that.speedKmh,_that.bearingDeg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude, @JsonKey(name: 'recorded_at')  DateTime recordedAt, @JsonKey(name: 'speed_kmh')  double? speedKmh, @JsonKey(name: 'bearing_deg')  double? bearingDeg)?  $default,) {final _that = this;
switch (_that) {
case _TelemetryPing() when $default != null:
return $default(_that.latitude,_that.longitude,_that.recordedAt,_that.speedKmh,_that.bearingDeg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TelemetryPing implements TelemetryPing {
  const _TelemetryPing({required this.latitude, required this.longitude, @JsonKey(name: 'recorded_at') required this.recordedAt, @JsonKey(name: 'speed_kmh') this.speedKmh, @JsonKey(name: 'bearing_deg') this.bearingDeg});
  factory _TelemetryPing.fromJson(Map<String, dynamic> json) => _$TelemetryPingFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override@JsonKey(name: 'recorded_at') final  DateTime recordedAt;
@override@JsonKey(name: 'speed_kmh') final  double? speedKmh;
@override@JsonKey(name: 'bearing_deg') final  double? bearingDeg;

/// Create a copy of TelemetryPing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelemetryPingCopyWith<_TelemetryPing> get copyWith => __$TelemetryPingCopyWithImpl<_TelemetryPing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TelemetryPingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TelemetryPing&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.bearingDeg, bearingDeg) || other.bearingDeg == bearingDeg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,recordedAt,speedKmh,bearingDeg);

@override
String toString() {
  return 'TelemetryPing(latitude: $latitude, longitude: $longitude, recordedAt: $recordedAt, speedKmh: $speedKmh, bearingDeg: $bearingDeg)';
}


}

/// @nodoc
abstract mixin class _$TelemetryPingCopyWith<$Res> implements $TelemetryPingCopyWith<$Res> {
  factory _$TelemetryPingCopyWith(_TelemetryPing value, $Res Function(_TelemetryPing) _then) = __$TelemetryPingCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude,@JsonKey(name: 'recorded_at') DateTime recordedAt,@JsonKey(name: 'speed_kmh') double? speedKmh,@JsonKey(name: 'bearing_deg') double? bearingDeg
});




}
/// @nodoc
class __$TelemetryPingCopyWithImpl<$Res>
    implements _$TelemetryPingCopyWith<$Res> {
  __$TelemetryPingCopyWithImpl(this._self, this._then);

  final _TelemetryPing _self;
  final $Res Function(_TelemetryPing) _then;

/// Create a copy of TelemetryPing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? recordedAt = null,Object? speedKmh = freezed,Object? bearingDeg = freezed,}) {
  return _then(_TelemetryPing(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,bearingDeg: freezed == bearingDeg ? _self.bearingDeg : bearingDeg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on

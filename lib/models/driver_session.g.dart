// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverSession _$DriverSessionFromJson(Map<String, dynamic> json) =>
    _DriverSession(
      driverId: (json['driver_id'] as num).toInt(),
      token: json['token'] as String,
    );

Map<String, dynamic> _$DriverSessionToJson(_DriverSession instance) =>
    <String, dynamic>{'driver_id': instance.driverId, 'token': instance.token};

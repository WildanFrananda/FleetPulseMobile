// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    _SessionResponse(
      token: json['token'] as String,
      driverId: const DriverIdConverter().fromJson(
        (json['driver_id'] as num).toInt(),
      ),
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$SessionResponseToJson(_SessionResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'driver_id': const DriverIdConverter().toJson(instance.driverId),
      'expires_in': instance.expiresIn,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_ping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TelemetryPing _$TelemetryPingFromJson(Map<String, dynamic> json) =>
    _TelemetryPing(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      speedKmh: (json['speed_kmh'] as num?)?.toDouble(),
      bearingDeg: (json['bearing_deg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TelemetryPingToJson(_TelemetryPing instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'recorded_at': instance.recordedAt.toIso8601String(),
      'speed_kmh': instance.speedKmh,
      'bearing_deg': instance.bearingDeg,
    };

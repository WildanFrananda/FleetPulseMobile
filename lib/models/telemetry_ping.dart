import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_ping.freezed.dart';
part 'telemetry_ping.g.dart';

@freezed
abstract class TelemetryPing with _$TelemetryPing {
  const factory TelemetryPing({
    required double latitude,
    required double longitude,
    @JsonKey(name: 'recorded_at') required DateTime recordedAt,
    @JsonKey(name: 'speed_kmh') double? speedKmh,
    @JsonKey(name: 'bearing_deg') double? bearingDeg,
  }) = _TelemetryPing;

  factory TelemetryPing.fromJson(Map<String, dynamic> json) =>
      _$TelemetryPingFromJson(json);
}

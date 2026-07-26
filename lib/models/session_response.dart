import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_response.freezed.dart';
part 'session_response.g.dart';

@freezed
abstract class SessionResponse with _$SessionResponse {
  const factory SessionResponse({
    required String token,
    @JsonKey(name: 'driver_id') @DriverIdConverter() required DriverId driverId,
    @JsonKey(name: 'expires_in') required int expiresIn,
  }) = _SessionResponse;

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);
}

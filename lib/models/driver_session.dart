import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_session.freezed.dart';
part 'driver_session.g.dart';

@freezed
abstract class DriverSession with _$DriverSession {
  const factory DriverSession({
    @JsonKey(name: 'driver_id') required int driverId,
    required String token,
  }) = _DriverSession;

  factory DriverSession.fromJson(Map<String, dynamic> json) =>
      _$DriverSessionFromJson(json);
}

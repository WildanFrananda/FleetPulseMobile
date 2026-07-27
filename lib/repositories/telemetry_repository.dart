import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';

abstract interface class TelemetryRepository {
  bool get isStreaming;

  Stream<TelemetryPing> get sent;

  Future<Result<Unit>> start();
  Future<void> stop();
  Future<void> openAppSettings();
  Future<void> dispose();
}

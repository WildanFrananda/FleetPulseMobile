import 'package:fleet_pulse_mobile/core/result.dart';
import 'package:fleet_pulse_mobile/models/models.dart';

abstract interface class ConnectionRepository {
  Stream<ConnectionStatus> get statusStream;
  Future<void> connect(DriverSession session);
  Future<void> disconnect();
  Future<Result<Unit>> sendPing(TelemetryPing ping);
}

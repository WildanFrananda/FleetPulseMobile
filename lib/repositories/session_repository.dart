import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';

abstract interface class SessionRepository {
  Future<DriverSession?> currentSession();
  Future<Result<DriverSession>> login({
    required String phone,
    required String password,
  });
  Future<void> logout();
}

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';

abstract interface class SessionRepository {
  Future<DriverSession?> currentSession();
  Future<Result<DriverSession>> login({
    required String phone,
    required String password,
  });
  Future<Result<RegisterResponse>> register({
    required String name,
    required String phone,
    required String password,
    required String vehiclePlate,
    required int capacityKg,
  });
  Future<void> logout();
}

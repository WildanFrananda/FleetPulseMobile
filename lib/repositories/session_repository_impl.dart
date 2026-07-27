import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/login_request.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/models/session_response.dart';
import 'package:fleet_pulse_mobile/repositories/session_repository.dart';
import 'package:fleet_pulse_mobile/services/auth/driver_api.dart';
import 'package:fleet_pulse_mobile/services/auth/token_store.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SessionRepository)
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._api, this._store);

  final DriverApi _api;
  final TokenStore _store;

  @override
  Future<DriverSession?> currentSession() => _store.read();

  @override
  Future<Result<DriverSession>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final SessionResponse res = await _api.login(
        new LoginRequest(phone: phone, password: password),
      );
      final DriverSession session = DriverSession(
        driverId: res.driverId,
        token: res.token,
      );
      final DateTime expiresAt = clock.now().toUtc().add(
        Duration(seconds: res.expiresIn),
      );

      await _store.save(session, expiresAt);

      return Ok<DriverSession>(session);
    } on DioException catch (e) {
      return Err<DriverSession>(_mapDio(e));
    } on Object {
      return const Err<DriverSession>(NetworkFailure());
    }
  }

  @override
  Future<Result<RegisterResponse>> register({
    required String name,
    required String phone,
    required String password,
    required String vehiclePlate,
    required int capacityKg,
  }) async {
    try {
      final RegisterResponse res = await _api.register(
        new RegisterRequest(
          name: name,
          phone: phone,
          password: password,
          vehiclePlate: vehiclePlate,
          capacityKg: capacityKg,
        ),
      );

      return Ok<RegisterResponse>(res);
    } on DioException catch (e) {
      return Err<RegisterResponse>(_mapDio(e));
    } on Object {
      return const Err<RegisterResponse>(NetworkFailure());
    }
  }

  Failure _mapDio(DioException e) {
    AppLogger.debug('login failed: HTTP ${e.response?.statusCode}');
    final Object? responseData = e.response?.data;
    final Map<String, dynamic>? dataMap = responseData is Map<String, dynamic>
        ? responseData
        : null;

    return switch (e.response?.statusCode) {
      401 => const AuthFailure('invalid phone or password'),
      400 => const ChannelFailure('phone and password are required'),
      422 => ChannelFailure(
        dataMap != null && dataMap['errors'] != null
            ? dataMap['errors'].toString()
            : 'registration validation failed',
      ),
      _ => const NetworkFailure(),
    };
  }

  @override
  Future<void> logout() => _store.clear();
}

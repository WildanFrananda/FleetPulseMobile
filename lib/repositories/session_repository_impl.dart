import 'package:dio/dio.dart';
import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/login_request.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
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
      final DriverSession session = await _api.login(
        new LoginRequest(phone: phone, password: password),
      );

      await _store.save(session);

      return Ok<DriverSession>(session);
    } on DioException catch (e) {
      return Err<DriverSession>(_mapDio(e));
    } on Object {
      return const Err<DriverSession>(NetworkFailure());
    }
  }

  Failure _mapDio(DioException e) {
    return switch (e.response?.statusCode) {
      401 => const AuthFailure(),
      400 => const ChannelFailure('phone and password are required'),
      _ => const NetworkFailure(),
    };
  }

  @override
  Future<void> logout() => _store.clear();
}

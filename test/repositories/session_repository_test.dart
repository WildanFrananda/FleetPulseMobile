import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/login_request.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/models/session_response.dart';
import 'package:fleet_pulse_mobile/repositories/session_repository_impl.dart';
import 'package:fleet_pulse_mobile/services/auth/driver_api.dart';
import 'package:fleet_pulse_mobile/services/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements DriverApi {}

class _MockStore extends Mock implements TokenStore {}

void main() {
  late _MockApi api;
  late _MockStore store;
  late SessionRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(const LoginRequest(phone: '', password: ''));
    registerFallbackValue(
      const DriverSession(driverId: DriverId(0), token: ''),
    );
    registerFallbackValue(new DateTime(2026));
  });

  setUp(() {
    api = new _MockApi();
    store = new _MockStore();
    sut = new SessionRepositoryImpl(api, store);
    when(() => store.save(any(), any())).thenAnswer((_) async {});
  });

  DioException dioWith(int code) => new DioException(
    requestOptions: new RequestOptions(path: '/driver/session'),
    response: new Response(
      requestOptions: new RequestOptions(path: '/driver/session'),
      statusCode: code,
    ),
  );

  test('201 stores session with expiry and returns Ok', () async {
    final DateTime now = DateTime.utc(2026, 1, 1);
    when(() => api.login(any())).thenAnswer(
      (_) async => const SessionResponse(
        token: 'tok',
        driverId: DriverId(9),
        expiresIn: 604800,
      ),
    );
    final Result<DriverSession> res = await withClock(
      Clock.fixed(now),
      () => sut.login(phone: '1', password: 'p'),
    );
    expect(res, isA<Ok<DriverSession>>());
    final List<dynamic> captured = verify(
      () => store.save(captureAny(), captureAny()),
    ).captured;
    expect((captured[0] as DriverSession).token, 'tok');
    expect(captured[1] as DateTime, now.add(const Duration(seconds: 604800)));
  });

  test('401 maps to AuthFailure', () async {
    when(() => api.login(any())).thenThrow(dioWith(401));
    final res = await sut.login(phone: '1', password: 'p');
    expect((res as Err<DriverSession>).failure, isA<AuthFailure>());
  });

  test('400 maps to ChannelFailure', () async {
    when(() => api.login(any())).thenThrow(dioWith(400));
    final res = await sut.login(phone: '1', password: 'p');
    expect((res as Err<DriverSession>).failure, isA<ChannelFailure>());
  });

  test('unexpected error maps to NetworkFailure', () async {
    when(() => api.login(any())).thenThrow(new Exception('boom'));
    final res = await sut.login(phone: '1', password: 'p');
    expect((res as Err<DriverSession>).failure, isA<NetworkFailure>());
  });
}

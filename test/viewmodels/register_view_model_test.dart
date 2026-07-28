import 'package:fleet_pulse_mobile/core/failure.dart';
import 'package:fleet_pulse_mobile/core/result.dart';
import 'package:fleet_pulse_mobile/models/ids.dart';
import 'package:fleet_pulse_mobile/models/register_response.dart';
import 'package:fleet_pulse_mobile/repositories/session_repository.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:fleet_pulse_mobile/viewmodels/register_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSession extends Mock implements SessionRepository {}

void main() {
  late _MockSession session;
  late AppRouterState router;
  late RegisterViewModel sut;

  void fill(RegisterViewModel vm) {
    vm
      ..setName('Budi')
      ..setPhone('0812')
      ..setPassword('supersecret1')
      ..setVehiclePlate('B 1234 XY')
      ..setCapacityKg('200');
  }

  setUp(() {
    session = new _MockSession();
    router = new AppRouterState();
    sut = new RegisterViewModel(router, session);
  });

  test('empty fields set an error and skip register', () async {
    await sut.submit();
    expect(sut.error, isNotNull);
    verifyNever(
      () => session.register(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
        vehiclePlate: any(named: 'vehiclePlate'),
        capacityKg: any(named: 'capacityKg'),
      ),
    );
  });

  test('short password is rejected', () async {
    sut
      ..setName('Budi')
      ..setPhone('0812')
      ..setPassword('short')
      ..setVehiclePlate('B 1');
    await sut.submit();
    expect(sut.error, contains('12'));
  });

  test('successful register surfaces the message', () async {
    when(
      () => session.register(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
        vehiclePlate: any(named: 'vehiclePlate'),
        capacityKg: any(named: 'capacityKg'),
      ),
    ).thenAnswer(
      (_) async => const Ok<RegisterResponse>(
        RegisterResponse(message: 'pending approval', driverId: DriverId(1)),
      ),
    );
    fill(sut);
    await sut.submit();
    expect(sut.successMessage, 'pending approval');
    expect(sut.error, isNull);
  });

  test('failed register surfaces the failure', () async {
    when(
      () => session.register(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
        vehiclePlate: any(named: 'vehiclePlate'),
        capacityKg: any(named: 'capacityKg'),
      ),
    ).thenAnswer(
      (_) async => const Err<RegisterResponse>(ChannelFailure('name taken')),
    );
    fill(sut);
    await sut.submit();
    expect(sut.error, 'name taken');
  });
}

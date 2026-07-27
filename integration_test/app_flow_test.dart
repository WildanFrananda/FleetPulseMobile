import 'dart:async';

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/di/injection.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/connection_repository.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository.dart';
import 'package:fleet_pulse_mobile/repositories/session_repository.dart';
import 'package:fleet_pulse_mobile/repositories/telemetry_repository.dart';
import 'package:fleet_pulse_mobile/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class FakeSession implements SessionRepository {
  DriverSession? stored;

  @override
  Future<DriverSession?> currentSession() async => stored;

  @override
  Future<Result<DriverSession>> login({
    required String phone,
    required String password,
  }) async {
    stored = const DriverSession(driverId: DriverId(1), token: 't');

    return Ok<DriverSession>(stored!);
  }

  @override
  Future<Result<RegisterResponse>> register({
    required String name,
    required String phone,
    required String password,
    required String vehiclePlate,
    required int capacityKg,
  }) async {
    return const Ok<RegisterResponse>(
      RegisterResponse(
        message:
            'Registration successful. Your account is pending admin approval.',
        driverId: DriverId(1),
      ),
    );
  }

  @override
  Future<void> logout() async => stored = null;
}

class FakeConnection implements ConnectionRepository {
  final StreamController<ConnectionStatus> _status =
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<void> _expired = StreamController<void>.broadcast();

  @override
  Stream<ConnectionStatus> get statusStream => _status.stream;

  @override
  Stream<void> get sessionExpired => _expired.stream;

  @override
  Future<void> connect(DriverSession session) async =>
      _status.add(ConnectionStatus.connected);

  @override
  Future<void> disconnect() async => _status.add(ConnectionStatus.disconnected);

  @override
  Future<Result<Unit>> sendPing(TelemetryPing ping) async =>
      const Ok<Unit>(Unit.unit);

  @override
  Future<Result<Unit>> setStatus(String status) async =>
      const Ok<Unit>(Unit.unit);

  @override
  void onResume() {}

  void dispose() {
    unawaited(_status.close());
    unawaited(_expired.close());
  }
}

class FakeOrders implements OrderRepository {
  final StreamController<Order?> _orders = StreamController<Order?>.broadcast();

  void assign(Order? order) => _orders.add(order);

  @override
  Stream<Order?> watchActiveOrder() => _orders.stream;
  @override
  Future<Result<Unit>> pickup(OrderId orderId) async =>
      const Ok<Unit>(Unit.unit);
  @override
  Future<Result<Unit>> delivered(OrderId orderId) async =>
      const Ok<Unit>(Unit.unit);

  void dispose() {
    unawaited(_orders.close());
  }
}

class FakeTelemetry implements TelemetryRepository {
  bool _streaming = false;
  final StreamController<TelemetryPing> _sent =
      StreamController<TelemetryPing>.broadcast();

  @override
  bool get isStreaming => _streaming;
  @override
  Stream<TelemetryPing> get sent => _sent.stream;
  @override
  Future<Result<Unit>> start() async {
    _streaming = true;
    return const Ok<Unit>(Unit.unit);
  }

  @override
  Future<void> stop() async => _streaming = false;
  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> dispose() async {
    await _sent.close();
  }
}

Order _order(OrderStatus status) => new Order(
  id: const OrderId(5),
  status: status,
  weightKg: 1,
  pickup: const LatLng(latitude: 1, longitude: 2),
  dropoff: const LatLng(latitude: 3, longitude: 4),
  assignedAt: DateTime.utc(2026),
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeSession session;
  late FakeOrders orders;

  setUp(() async {
    await configureDependencies();
    getIt.allowReassignment = true;
    session = new FakeSession();
    orders = new FakeOrders();
    getIt
      ..registerLazySingleton<SessionRepository>(() => session)
      ..registerLazySingleton<ConnectionRepository>(FakeConnection.new)
      ..registerLazySingleton<OrderRepository>(() => orders)
      ..registerLazySingleton<TelemetryRepository>(FakeTelemetry.new);
  });

  tearDown(() async => getIt.reset());

  testWidgets('login -> tracking -> order -> delivered', (tester) async {
    session.stored = null;

    await tester.pumpWidget(const FleetPulseApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '0812');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('On duty'), findsOneWidget);

    orders.assign(_order(OrderStatus.assigned));
    await tester.pumpAndSettle();
    expect(find.text('Picked up'), findsOneWidget);

    await tester.tap(find.text('Picked up'));
    await tester.pumpAndSettle();

    orders.assign(_order(OrderStatus.pickedUp));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivered'));
    await tester.pumpAndSettle();

    expect(find.text('On duty'), findsOneWidget);
  });
}

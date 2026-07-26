import 'dart:async';

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/connection_repository.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository.dart';
import 'package:fleet_pulse_mobile/repositories/session_repository.dart';
import 'package:fleet_pulse_mobile/repositories/telemetry_repository.dart';
import 'package:fleet_pulse_mobile/state/state.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';

@injectable
class TrackingViewModel extends ChangeNotifier {
  TrackingViewModel(
    this._router,
    this._connection,
    this._orders,
    this._telemetry,
    this._session,
  ) {
    _connSub = _connection.statusStream.listen(_onStatus);
    _pingSub = _telemetry.sent.listen(_onPing);
    _orderSub = _orders.watchActiveOrder().listen(_onOrder);
    _authSub = _connection.sessionExpired.listen(
      (_) => unawaited(_onExpired()),
    );
    unawaited(_init());
  }

  final AppRouterState _router;
  final ConnectionRepository _connection;
  final OrderRepository _orders;
  final TelemetryRepository _telemetry;
  final SessionRepository _session;

  StreamSubscription<ConnectionStatus>? _connSub;
  StreamSubscription<TelemetryPing>? _pingSub;
  StreamSubscription<Order?>? _orderSub;
  StreamSubscription<void>? _authSub;

  TrackingState _state = const TrackingConnecting();
  ConnectionStatus _conn = ConnectionStatus.connecting;
  bool _onDuty = false;
  TelemetryPing? _lastPing;
  String? _message;
  bool _permissionBlocked = false;
  int? _showOrderId;

  TrackingState get state => _state;

  Future<void> openSettings() => _telemetry.openAppSettings();

  Future<void> _init() async {
    final DriverSession? s = await _session.currentSession();

    if (s == null) {
      _router.replaceAll(const LoginRoute());

      return;
    }

    await _connection.connect(s);
  }

  Future<void> toggleDuty() async {
    if (_onDuty) {
      await _telemetry.stop();
      await _connection.setStatus('offline');

      _onDuty = false;
    } else {
      final Result<Unit> res = await _telemetry.start();

      switch (res) {
        case Ok<Unit>():
          _onDuty = true;
          await _connection.setStatus('online');
        case Err<Unit>(:final failure):
          _message = failure.message;
          _permissionBlocked = failure is PermissionFailure;
      }
    }

    _recompute();
  }

  Future<void> logout() async {
    await _telemetry.stop();
    await _connection.setStatus('offline');
    await _session.logout();
    await _connection.disconnect();
    _router.replaceAll(const LoginRoute());
  }

  Future<void> _onExpired() async {
    await _telemetry.stop();
    await _session.logout();
    await _connection.disconnect();
    _router.replaceAll(const LoginRoute());
  }

  void _onStatus(ConnectionStatus s) {
    _conn = s;
    _recompute();
  }

  void _onPing(TelemetryPing p) {
    _lastPing = p;
    _recompute();
  }

  void _onOrder(Order? order) {
    if (order == null) {
      _showOrderId = null;

      return;
    }

    if (order.id.value == _showOrderId) {
      return;
    }

    _showOrderId = order.id.value;
    _router.push(new OrderRoute(order: order));
  }

  void _recompute() {
    _state = switch (_conn) {
      ConnectionStatus.disconnected => const TrackingOffline(),
      ConnectionStatus.connecting => const TrackingConnecting(),
      ConnectionStatus.reconnecting => const TrackingConnecting(),
      ConnectionStatus.connected => TrackingOnline(
        connection: _conn,
        onDuty: _onDuty,
        permissionBlocked: _permissionBlocked,
        lastPing: _lastPing,
        lastMessage: _message,
      ),
    };
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_connSub?.cancel());
    unawaited(_pingSub?.cancel());
    unawaited(_orderSub?.cancel());
    unawaited(_authSub?.cancel());
    super.dispose();
  }
}

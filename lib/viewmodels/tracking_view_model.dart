import 'dart:async';

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/connection_repository.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository.dart';
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
  ) {
    _connSub = _connection.statusStream.listen(_onStatus);
    _pingSub = _telemetry.sent.listen(_onPing);
    _orderSub = _orders.watchActiveOrder().listen(_onOrder);
  }

  final AppRouterState _router;
  final ConnectionRepository _connection;
  final OrderRepository _orders;
  final TelemetryRepository _telemetry;

  StreamSubscription<ConnectionStatus>? _connSub;
  StreamSubscription<TelemetryPing>? _pingSub;
  StreamSubscription<Order?>? _orderSub;

  TrackingState _state = const TrackingOffline();
  ConnectionStatus _conn = ConnectionStatus.disconnected;
  bool _onDuty = false;
  TelemetryPing? _lastPing;
  String? _message;

  int _driverId = 1;
  String _token = '';

  TrackingState get state => _state;

  void setDriverId(String v) => _driverId = int.tryParse(v) ?? _driverId;
  void setToken(String v) => _token = v.trim();

  Future<void> connect() async {
    if (_token.isEmpty) {
      _message = 'token empty';
      _recompute();

      return;
    }

    await _connection.connect(
      DriverSession(driverId: DriverId(_driverId), token: _token),
    );
  }

  Future<void> disconnect() async {
    await _telemetry.stop();
    _onDuty = false;
    await _connection.disconnect();
  }

  Future<void> toggleOnDuty() async {
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
      }
    }

    _recompute();
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
    if (order != null) {
      _router.push(new OrderRoute(order: order));
    }
  }

  void _recompute() {
    _state = switch (_conn) {
      ConnectionStatus.disconnected => const TrackingOffline(),
      ConnectionStatus.connecting => const TrackingConnecting(),
      ConnectionStatus.reconnecting => const TrackingConnecting(),
      ConnectionStatus.connected => new TrackingOnline(
        connection: _conn,
        onDuty: _onDuty,
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
    super.dispose();
  }
}

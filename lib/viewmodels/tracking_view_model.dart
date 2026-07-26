import 'dart:async';

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/connection_repository.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository.dart';
import 'package:fleet_pulse_mobile/state/state.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';

@injectable
class TrackingViewModel extends ChangeNotifier {
  TrackingViewModel(this._router, this._connection, this._order) {
    _connSub = _connection.statusStream.listen(_onStatus);
    _orderSub = _order.watchActiveOrder().listen(_onOrder);
  }

  final AppRouterState _router;
  final ConnectionRepository _connection;
  final OrderRepository _order;

  StreamSubscription<ConnectionStatus>? _connSub;
  StreamSubscription<Order?>? _orderSub;

  TrackingState _state = const TrackingOffline();
  int _driverId = 1;
  String _token = '';
  String? _lastMessage;

  TrackingState get state => _state;

  void setDriverId(String v) => _driverId = int.tryParse(v) ?? _driverId;
  void setToken(String v) => _token = v.trim();

  Future<void> connect() async {
    if (_token.isEmpty) {
      _lastMessage = 'token empty';
      _emitOnlineMessage();

      return;
    }

    await _connection.connect(
      DriverSession(driverId: DriverId(_driverId), token: _token),
    );
  }

  Future<void> disconnect() => _connection.disconnect();

  Future<void> sendTestPing() async {
    final res = await _connection.sendPing(
      new TelemetryPing(
        latitude: -6.200000,
        longitude: 106.816666,
        recordedAt: DateTime.now().toUtc(),
        speedKmh: 42,
        bearingDeg: 90,
      ),
    );
    _lastMessage = res.fold(
      (_) => 'ping ok',
      (Failure f) => 'ping failed: ${f.message}',
    );
    _emitOnlineMessage();
  }

  void _onStatus(ConnectionStatus s) {
    _state = switch (s) {
      ConnectionStatus.disconnected => const TrackingOffline(),
      ConnectionStatus.connecting => const TrackingConnecting(),
      ConnectionStatus.reconnecting => const TrackingConnecting(),
      ConnectionStatus.connected => TrackingOnline(
        connection: s,
        lastMessage: _lastMessage,
      ),
    };
    notifyListeners();
  }

  void _onOrder(Order? order) {
    if (order != null) {
      _router.push(OrderRoute(order: order));
    }
  }

  void _emitOnlineMessage() {
    if (_state is TrackingOnline) {
      _state = TrackingOnline(
        connection: ConnectionStatus.connected,
        lastMessage: _lastMessage,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_connSub?.cancel());
    unawaited(_orderSub?.cancel());
    super.dispose();
  }
}

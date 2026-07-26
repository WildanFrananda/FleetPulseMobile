import 'dart:async';

import 'package:fleet_pulse_mobile/models/telemetry_ping.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_event.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/order.dart';
import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';

@injectable
class TrackingViewModel extends ChangeNotifier {
  TrackingViewModel(this._router, this._channel) {
    _statusSub = _channel.statusStream.listen(_onStatus);
    _eventSub = _channel.events.listen(_onEvent);
  }

  final AppRouterState _router;
  final ChannelClient _channel;

  StreamSubscription<ConnectionStatus>? _statusSub;
  StreamSubscription<ChannelEvent>? _eventSub;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _lastReply = '';
  int _driverId = 1;
  String _token = '';

  ConnectionStatus get status => _status;
  String get lastReply => _lastReply;
  bool get connected => _status == ConnectionStatus.connected;

  void setDriverId(String v) => _driverId = int.tryParse(v) ?? _driverId;
  void setToken(String v) => _token = v.trim();

  Future<void> connect() async {
    if (_token.isEmpty) {
      _lastReply = 'token empty';
      notifyListeners();

      return;
    }
  }

  Future<void> disconnect() => _channel.disconnect();

  Future<void> sendTestPing() async {
    try {
      final ChannelReply reply = await _channel.ping(
        new TelemetryPing(
          latitude: -6.200000,
          longitude: 106.816666,
          recordedAt: DateTime.now().toUtc(),
          speedKmh: 42,
          bearingDeg: 90,
        ),
      );
      _lastReply = reply.isOk ? 'ping ok' : 'ping error: ${reply.reason}';
    } on Object catch (e) {
      _lastReply = 'ping failed $e';
    }
  }

  void _onStatus(ConnectionStatus s) {
    _status = s;
    notifyListeners();
  }

  void _onEvent(ChannelEvent e) {
    final Object? raw = e.event == 'acitve_order'
        ? e.payload['order']
        : e.payload;

    if (raw == null) {
      return;
    }

    if (e.event == 'active_order' ||
        e.event == 'order_assigned' ||
        e.event == 'order_updated') {
      final Order order = Order.fromJson(
        (raw as Map<dynamic, dynamic>).cast<String, dynamic>(),
      );

      _router.push(OrderRoute(order: order));
    }
  }

  @override
  Future<void> dispose() async {
    await _statusSub?.cancel();
    await _eventSub?.cancel();
    super.dispose();
  }
}

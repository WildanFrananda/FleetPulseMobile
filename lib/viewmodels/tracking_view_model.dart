import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/lat_lng.dart';
import 'package:fleet_pulse_mobile/models/order.dart';
import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';

@injectable
class TrackingViewModel extends ChangeNotifier {
  TrackingViewModel(this._router);

  final AppRouterState _router;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  bool _online = false;

  ConnectionStatus get status => _status;
  bool get online => _online;

  /// M0 stub: flip duty flag. TODO(M2): connect socket + start GPS stream.
  void toggleOnline() {
    _online = !_online;
    _status = _online
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected;
    notifyListeners();
  }

  /// M0 nav demo: push a fake order. TODO(M3): triggered by `order_assigned`.
  void simulateIncomingOrder() {
    final Order demo = new Order(
      id: 1,
      status: OrderStatus.assigned,
      weightKg: 12,
      pickup: const LatLng(latitude: -6.2, longitude: 106.8),
      dropoff: const LatLng(latitude: -6.3, longitude: 106.9),
      assignedAt: DateTime.now().toUtc(),
    );
    _router.push(OrderRoute(order: demo));
  }
}

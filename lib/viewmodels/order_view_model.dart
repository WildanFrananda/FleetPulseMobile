import 'package:fleet_pulse_mobile/models/order.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart' hide Order;

@injectable
class OrderViewModel extends ChangeNotifier {
  OrderViewModel(this._router);

  final AppRouterState _router;

  /// M0 stubs. TODO(M3): push `pickup`/`delivered` to the channel, retry until ok.
  void pickup(Order order) {}

  void delivered(Order order) {
    _router.pop();
  }

  void back() => _router.pop();
}

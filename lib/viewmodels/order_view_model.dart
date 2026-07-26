import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/order.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart' hide Order;

@injectable
class OrderViewModel extends ChangeNotifier {
  OrderViewModel(this._router, this._orders);

  final AppRouterState _router;
  final OrderRepository _orders;

  String? _error;
  bool _busy = false;

  String? get error => _error;
  bool get busy => _busy;

  Future<void> pickup(Order order) async {
    await _run(() => _orders.pickup(order.id));
  }

  Future<void> delivered(Order order) async {
    _busy = true;
    _error = null;
    notifyListeners();
    final res = await _orders.delivered(order.id);
    res.fold((_) => _router.pop(), (Failure f) {
      _error = f.message;
      _busy = false;
      notifyListeners();
    });
  }

  Future<void> _run(Future<Result<Unit>> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();

    final res = await action();

    res.fold((_) => _error = null, (Failure f) => _error = f.message);
    _busy = false;
    notifyListeners();
  }

  void back() => _router.pop();
}

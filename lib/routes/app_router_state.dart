import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouterState extends ChangeNotifier {
  final List<AppRoute> _stack = <AppRoute>[const SplashRoute()];

  List<AppRoute> get stack => List<AppRoute>.unmodifiable(_stack);

  void push(AppRoute route) {
    _stack.add(route);
    notifyListeners();
  }

  void replaceAll(AppRoute route) {
    _stack
      ..clear()
      ..add(route);
    notifyListeners();
  }

  bool pop() {
    if (_stack.length <= 1) {
      return false;
    }

    _stack.removeLast();
    notifyListeners();

    return true;
  }
}

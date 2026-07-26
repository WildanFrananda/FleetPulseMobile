import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._router);

  final AppRouterState _router;

  void devContinue() {
    _router.replaceAll(const TrackingRoute());
  }
}

import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._router);

  final AppRouterState _router;

  /// TODO(M4): call AuthService.login(phone, password) then route on success.
  void devContinue() {
    _router.replaceAll(const TrackingRoute());
  }
}

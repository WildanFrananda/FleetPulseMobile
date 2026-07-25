import 'dart:async';

import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashViewModel extends ChangeNotifier {
  SplashViewModel(this._router) {
    unawaited(_bootstrap());
  }

  final AppRouterState _router;

  /// TODO(M4): read TokenStore; if a valid session exists -> TrackingRoute.
  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _router.replaceAll(const LoginRoute());
  }
}

import 'dart:async';

import 'package:fleet_pulse_mobile/repositories/session_repository.dart';
import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashViewModel extends ChangeNotifier {
  SplashViewModel(this._router, this._session) {
    unawaited(_bootstrap());
  }

  final AppRouterState _router;
  final SessionRepository _session;

  Future<void> _bootstrap() async {
    final session = await _session.currentSession();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _router.replaceAll(
      session == null ? const LoginRoute() : const TrackingRoute(),
    );
  }
}

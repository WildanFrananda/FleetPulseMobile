import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class PendingApprovalViewModel extends ChangeNotifier {
  PendingApprovalViewModel(this._router);

  final AppRouterState _router;

  void backToLogin() => _router.replaceAll(const LoginRoute());
}

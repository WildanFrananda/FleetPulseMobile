import 'package:fleet_pulse_mobile/routes/app_route.dart';
import 'package:fleet_pulse_mobile/routes/app_router_state.dart';
import 'package:fleet_pulse_mobile/viewmodels/pending_approval_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backToLogin replaces the stack with LoginRoute', () {
    final AppRouterState router = new AppRouterState()
      ..push(const PendingApprovalRoute());
    PendingApprovalViewModel(router).backToLogin();
    expect(router.stack.last, isA<LoginRoute>());
    expect(router.stack.length, 1);
  });
}

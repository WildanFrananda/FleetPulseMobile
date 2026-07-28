import 'package:fleet_pulse_mobile/ui/screens/pending_approval_screen.dart';
import 'package:fleet_pulse_mobile/viewmodels/pending_approval_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockVm extends Mock implements PendingApprovalViewModel {}

void main() {
  testWidgets('renders message and returns to login', (
    WidgetTester tester,
  ) async {
    final _MockVm vm = new _MockVm();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<PendingApprovalViewModel>.value(
          value: vm,
          child: const PendingApprovalScreen(),
        ),
      ),
    );

    expect(
      find.text('Your account is awaiting admin approval'),
      findsOneWidget,
    );
    await tester.tap(find.text('Back to Login'));
    verify(vm.backToLogin).called(1);
  });
}

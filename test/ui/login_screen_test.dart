import 'package:fleet_pulse_mobile/ui/screens/login_screen.dart';
import 'package:fleet_pulse_mobile/viewmodels/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockVm extends Mock implements LoginViewModel {}

Future<void> _pump(WidgetTester tester, LoginViewModel vm) {
  return tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<LoginViewModel>.value(
        value: vm,
        child: const LoginScreen(),
      ),
    ),
  );
}

void main() {
  late _MockVm vm;

  setUp(() {
    vm = new _MockVm();
    when(() => vm.submit()).thenAnswer((_) async {});
  });

  testWidgets('renders fields and submits', (WidgetTester tester) async {
    when(() => vm.submitting).thenReturn(false);
    when(() => vm.error).thenReturn(null);
    await _pump(tester, vm);
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.tap(find.byType(FilledButton));
    verify(() => vm.submit()).called(1);
  });

  testWidgets('submitting shows spinner and disables button', (
    WidgetTester tester,
  ) async {
    when(() => vm.submitting).thenReturn(true);
    when(() => vm.error).thenReturn(null);
    await _pump(tester, vm);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    verifyNever(() => vm.submit());
  });

  testWidgets('shows error text', (WidgetTester tester) async {
    when(() => vm.submitting).thenReturn(false);
    when(() => vm.error).thenReturn('invalid_credentials');
    await _pump(tester, vm);
    expect(find.text('invalid_credentials'), findsOneWidget);
  });
}

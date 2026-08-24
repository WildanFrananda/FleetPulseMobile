import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/state/state.dart';
import 'package:fleet_pulse_mobile/ui/screens/order_screen.dart';
import 'package:fleet_pulse_mobile/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockVm extends Mock implements OrderViewModel {
  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  bool get hasListeners => false;
}

Order _order(OrderStatus status) => new Order(
  id: const OrderId(5),
  status: status,
  weightKg: 1,
  pickup: const LatLng(latitude: 1, longitude: 2),
  dropoff: const LatLng(latitude: 3, longitude: 4),
  assignedAt: DateTime.utc(2026),
);

Future<void> _pump(WidgetTester tester, OrderViewModel vm, Order order) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: ChangeNotifierProvider<OrderViewModel>.value(
        value: vm,
        child: OrderScreen(order: order),
      ),
    ),
  );
}

void main() {
  late _MockVm vm;

  setUpAll(() {
    registerFallbackValue(_order(OrderStatus.assigned));
  });

  setUp(() {
    vm = new _MockVm();
    when(() => vm.bind(any())).thenAnswer((_) async {});
    when(() => vm.pickup()).thenAnswer((_) async {});
    when(() => vm.delivered()).thenAnswer((_) async {});
    when(() => vm.back()).thenAnswer((_) async {});
    when(() => vm.podPhotoUrl).thenReturn(null);
    when(() => vm.podSignature).thenReturn(null);
  });

  testWidgets('assigned enables pickup, hides delivered button', (
    WidgetTester tester,
  ) async {
    final Order order = _order(OrderStatus.assigned);
    when(() => vm.state).thenReturn(new OrderShowing(order));
    await _pump(tester, vm, order);

    final ElevatedButton pickupBtn = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Mark as Picked Up'),
        matching: find.byType(ElevatedButton),
      ),
    );

    expect(pickupBtn.onPressed, isNotNull);
    expect(find.text('Mark as Delivered'), findsNothing);

    await tester.tap(find.text('Mark as Picked Up'));
    verify(() => vm.pickup()).called(1);
  });

  testWidgets('cancelled shows message and back button', (WidgetTester tester) async {
    when(() => vm.state).thenReturn(const OrderCancelled());
    await _pump(tester, vm, _order(OrderStatus.assigned));
    expect(find.text('Order cancelled'), findsOneWidget);
    await tester.tap(find.text('Back'));
    verify(() => vm.back()).called(1);
  });
}

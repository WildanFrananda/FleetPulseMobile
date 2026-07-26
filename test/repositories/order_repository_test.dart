import 'dart:async';

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository_impl.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockChannel extends Mock implements ChannelClient {}

void main() {
  late _MockChannel channel;
  late StreamController<ChannelEvent> events;
  late OrderRepositoryImpl sut;

  Map<String, dynamic> orderJson(int id, String status) => <String, dynamic>{
    'id': id,
    'status': status,
    'weight_kg': 10,
    'pickup': <String, dynamic>{'latitude': 1.0, 'longitude': 2.0},
    'dropoff': <String, dynamic>{'latitude': 3.0, 'longitude': 4.0},
    'assigned_at': '2026-01-01T00:00:00Z',
  };

  setUp(() {
    channel = new _MockChannel();
    events = StreamController<ChannelEvent>.broadcast();
    when(() => channel.events).thenAnswer((_) => events.stream);
    sut = new OrderRepositoryImpl(channel);
  });

  tearDown(() => events.close());

  test('maps order_assigned to Order', () async {
    final Future<Order?> future = sut.watchActiveOrder().first;
    await Future<void>.delayed(Duration.zero);
    events.add(new ChannelEvent('order_assigned', orderJson(1, 'assigned')));
    final Order? order = await future;
    expect(order!.id.value, 1);
    expect(order.status, OrderStatus.assigned);
  });

  test('active_order null yields null', () async {
    final Future<Order?> future = sut.watchActiveOrder().first;
    await Future<void>.delayed(Duration.zero);
    events.add(
      const ChannelEvent('active_order', <String, dynamic>{'order': null}),
    );
    expect(await future, isNull);
  });

  test('order_updated cancelled yields null', () async {
    final Future<Order?> future = sut.watchActiveOrder().first;
    await Future<void>.delayed(Duration.zero);
    events.add(new ChannelEvent('order_updated', orderJson(2, 'cancelled')));
    expect(await future, isNull);
  });

  test('pickup ok returns Ok', () async {
    when(
      () => channel.pickup(any()),
    ).thenAnswer((_) async => const ChannelReply('ok', <String, dynamic>{}));
    final res = await sut.pickup(const OrderId(1));
    expect(res, isA<Ok<Unit>>());
    verify(() => channel.pickup(1)).called(1);
  });

  test('pickup terminal error returns Err without retry', () async {
    when(() => channel.pickup(any())).thenAnswer(
      (_) async => const ChannelReply('error', <String, dynamic>{
        'reason': 'invalid_transition',
      }),
    );
    final res = await sut.pickup(const OrderId(1));
    expect(res, isA<Err<Unit>>());
    verify(() => channel.pickup(1)).called(1);
  });
}

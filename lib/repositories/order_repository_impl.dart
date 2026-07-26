import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/order_repository.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_event.dart';
import 'package:fleet_pulse_mobile/state/state.dart';
import 'package:injectable/injectable.dart' hide Order;

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._channel);

  final ChannelClient _channel;

  @override
  Stream<Order?> watchActiveOrder() async* {
    await for (final ChannelEvent e in _channel.events) {
      final ServerEvent? event = _toServerEvent(e);

      if (event == null) {
        continue;
      }

      yield switch (event) {
        ActiveOrderEvent(:final Order? order) => order,
        OrderAssignedEvent(:final Order order) => order,
        OrderUpdatedEvent(:final Order order) =>
          order.status == OrderStatus.cancelled ? null : order,
      };
    }
  }

  @override
  Future<Result<Unit>> pickup(OrderId orderId) =>
      _lifecycle(() => _channel.pickup(orderId.value));

  @override
  Future<Result<Unit>> delivered(OrderId orderId) =>
      _lifecycle(() => _channel.delivered(orderId.value));

  Future<Result<Unit>> _lifecycle(
    Future<ChannelReply> Function() action,
  ) async {
    try {
      final ChannelReply reply = await action();

      return reply.isOk
          ? const Ok<Unit>(Unit.unit)
          : Err<Unit>(failureFromReason(reply.reason));
    } on ChannelException {
      return const Err<Unit>(NetworkFailure());
    } on Object {
      return const Err<Unit>(NetworkFailure());
    }
  }

  ServerEvent? _toServerEvent(ChannelEvent e) {
    Map<String, dynamic> asOrder(Object? raw) =>
        (raw as Map<dynamic, dynamic>).cast<String, dynamic>();

    return switch (e.event) {
      'active_order' => ActiveOrderEvent(
        e.payload['order'] == null
            ? null
            : Order.fromJson(asOrder(e.payload['order'])),
      ),
      'order_assigned' => OrderAssignedEvent(
        Order.fromJson(asOrder(e.payload)),
      ),
      'order_updated' => OrderUpdatedEvent(Order.fromJson(asOrder(e.payload))),
      _ => null,
    };
  }
}

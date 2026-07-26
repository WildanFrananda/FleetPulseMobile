import 'package:fleet_pulse_mobile/models/order.dart';
import 'package:fleet_pulse_mobile/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final OrderViewModel vm = context.watch<OrderViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id.value}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Status: ${order.status.name}'),
            Text('Weight: ${order.weightKg} kg'),
            Text('Pickup: ${order.pickup.latitude}, ${order.pickup.longitude}'),
            Text(
              'Dropoff: ${order.dropoff.latitude}, ${order.dropoff.longitude}',
            ),
            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: ${vm.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            FilledButton(
              onPressed: vm.busy ? null : () => vm.pickup(order),
              child: const Text('Picked up'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: vm.busy ? null : () => vm.delivered(order),
              child: const Text('Delivered'),
            ),
          ],
        ),
      ),
    );
  }
}

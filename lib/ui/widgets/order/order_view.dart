part of '../../screens/order_screen.dart';

class _OrderView extends StatelessWidget {
  const _OrderView({
    required this.vm,
    required this.order,
    required this.submitting,
    required this.error,
  });

  final OrderViewModel vm;
  final Order order;
  final bool submitting;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final bool canPickup = order.status == OrderStatus.assigned;
    final bool canDeliver = order.status == OrderStatus.pickedUp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Status: ${order.status.name}'),
        Text('Weight: ${order.weightKg} kg'),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Pickup: ${order.pickup.latitude}, ${order.pickup.longitude}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.navigation_outlined),
            onPressed: vm.navigateToPickup,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Dropoff: ${order.dropoff.latitude}, ${order.dropoff.longitude}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.navigation_outlined),
            onPressed: vm.navigateToDropoff,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const Spacer(),
        if (submitting) const LinearProgressIndicator(),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: (canPickup && !submitting) ? vm.pickup : null,
          child: const Text('Picked up'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: (canDeliver && !submitting) ? vm.delivered : null,
          child: const Text('Delivered'),
        ),
      ],
    );
  }
}

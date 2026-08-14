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
        if (canDeliver) ...<Widget>[
          const Divider(height: 24),
          const Text(
            'Proof of Delivery (POD)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(
                    vm.podPhotoUrl != null
                        ? Icons.check_circle
                        : Icons.camera_alt,
                    color: vm.podPhotoUrl != null ? Colors.green : null,
                  ),
                  label: Text(
                    vm.podPhotoUrl != null ? 'Photo Attached' : 'Capture Photo',
                  ),
                  onPressed: () {
                    vm.setPodPhoto(
                      'https://storage.fleetpulse.io/pod/photo_${order.id.value}.jpg',
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(
                    vm.podSignature != null ? Icons.check_circle : Icons.draw,
                    color: vm.podSignature != null ? Colors.green : null,
                  ),
                  label: Text(
                    vm.podSignature != null ? 'Signed' : 'Add Signature',
                  ),
                  onPressed: () {
                    vm.setPodSignature(
                      'data:image/svg+xml;base64,PHN2Zz48cGF0aCBkPSJNMTAgMTBMMjAgMjAiLz48L3N2Zz4=',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
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

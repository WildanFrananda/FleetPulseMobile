part of '../../screens/tracking_screen.dart';

class _ConnectView extends StatelessWidget {
  const _ConnectView({required this.vm});

  final TrackingViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'driver_id (dev)'),
          onChanged: vm.setDriverId,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(labelText: 'token (dev)'),
          onChanged: vm.setToken,
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: vm.connect, child: const Text('Connect')),
      ],
    );
  }
}

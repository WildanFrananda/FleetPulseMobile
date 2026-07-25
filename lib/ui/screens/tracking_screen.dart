import 'package:fleet_pulse_mobile/viewmodels/tracking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackingViewModel vm = context.watch<TrackingViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Connection: ${vm.status.name}'),
            const SizedBox(height: 8),
            Text('On duty: ${vm.online}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: vm.toggleOnline,
              child: Text(vm.online ? 'Go offline' : 'Go online'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: vm.simulateIncomingOrder,
              child: const Text('Simulate order (dev)'),
            ),
          ],
        ),
      ),
    );
  }
}

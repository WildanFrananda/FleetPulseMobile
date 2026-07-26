import 'package:fleet_pulse_mobile/viewmodels/tracking_view_model.dart';
import 'package:flutter/material.dart';

class ConnectView extends StatelessWidget {
  const ConnectView({required this.vm, super.key});

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

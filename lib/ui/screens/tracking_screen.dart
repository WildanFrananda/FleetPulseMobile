import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/viewmodels/tracking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  Color _statusColor(ConnectionStatus s) {
    return switch (s) {
      ConnectionStatus.connected => Colors.green,
      ConnectionStatus.connecting => Colors.orange,
      ConnectionStatus.reconnecting => Colors.orange,
      ConnectionStatus.disconnected => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final TrackingViewModel vm = context.watch<TrackingViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trakcing'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                Icon(Icons.circle, size: 12, color: _statusColor(vm.status)),
                const SizedBox(width: 6),
                Text(vm.status.name),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'driver_id (dev)'),
              onChanged: vm.setToken,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'token (dev)'),
              onChanged: vm.setToken,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: vm.connected ? vm.disconnect : vm.connect,
              child: Text(vm.connected ? 'Disconnect' : 'Connect'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: vm.connected ? vm.sendTestPing : null,
              child: const Text('Send test ping'),
            ),
            const SizedBox(height: 16),
            Text('Last reply: ${vm.lastReply}'),
          ],
        ),
      ),
    );
  }
}

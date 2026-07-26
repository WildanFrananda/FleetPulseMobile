import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/viewmodels/tracking_view_model.dart';
import 'package:flutter/material.dart';

class OnlineView extends StatelessWidget {
  const OnlineView({
    required this.connection,
    required this.message,
    required this.vm,
    super.key,
  });

  final TrackingViewModel vm;
  final ConnectionStatus connection;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.circle, size: 12, color: Colors.green),
            const SizedBox(width: 6),
            Text(connection.name),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: vm.sendTestPing,
          child: const Text('Send test ping'),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: vm.disconnect, child: const Text('Disconnect')),
        const SizedBox(height: 16),
        if (message != null) Text('Last: $message'),
      ],
    );
  }
}

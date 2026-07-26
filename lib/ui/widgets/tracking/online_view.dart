part of '../../screens/tracking_screen.dart';

class _OnlineView extends StatelessWidget {
  const _OnlineView({
    required this.vm,
    required this.connection,
    required this.onDuty,
    required this.lastPing,
    required this.message,
  });

  final TrackingViewModel vm;
  final ConnectionStatus connection;
  final bool onDuty;
  final TelemetryPing? lastPing;
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
        SwitchListTile(
          title: const Text('On duty'),
          value: onDuty,
          onChanged: (_) => vm.toggleOnDuty(),
        ),
        const SizedBox(height: 8),
        if (lastPing != null)
          Text(
            'Last ping: ${lastPing!.latitude.toStringAsFixed(5)}, '
            '${lastPing!.longitude.toStringAsFixed(5)}',
          )
        else
          const Text('Last ping: -'),
        const Spacer(),
        if (message != null) Text(message!),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: vm.disconnect,
          child: const Text('disconnect'),
        ),
      ],
    );
  }
}

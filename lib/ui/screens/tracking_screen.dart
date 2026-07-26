import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/telemetry_ping.dart';
import 'package:fleet_pulse_mobile/state/state.dart';
import 'package:fleet_pulse_mobile/viewmodels/tracking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part '../widgets/tracking/connect_view.dart';
part '../widgets/tracking/online_view.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackingViewModel vm = context.watch<TrackingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (vm.state) {
          TrackingOffline() => _ConnectView(vm: vm),
          TrackingConnecting() => const Center(
            child: CircularProgressIndicator(),
          ),
          TrackingOnline(
            :final ConnectionStatus connection,
            :final bool onDuty,
            :final TelemetryPing? lastPing,
            :final String? lastMessage,
          ) =>
            _OnlineView(
              vm: vm,
              connection: connection,
              onDuty: onDuty,
              lastPing: lastPing,
              message: lastMessage,
            ),
          TrackingFailed(:final Failure failure) => Center(
            child: Center(child: Text('Failed: ${failure.message}')),
          ),
        },
      ),
    );
  }
}

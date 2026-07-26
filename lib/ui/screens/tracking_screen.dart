import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/state/state.dart';
import 'package:fleet_pulse_mobile/ui/widgets/tracking/connect_view.dart';
import 'package:fleet_pulse_mobile/ui/widgets/tracking/online_view.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (vm.state) {
          TrackingOffline() => ConnectView(vm: vm),
          TrackingConnecting() => const Center(
            child: CircularProgressIndicator(),
          ),
          TrackingOnline(
            :final ConnectionStatus connection,
            :final String? lastMessage,
          ) =>
            OnlineView(vm: vm, connection: connection, message: lastMessage),
          TrackingFailed(:final Failure failure) => Center(
            child: Text('Failed: ${failure.message}'),
          ),
        },
      ),
    );
  }
}

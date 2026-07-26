import 'package:fleet_pulse_mobile/core/failure.dart';
import 'package:fleet_pulse_mobile/models/enums.dart';

sealed class TrackingState {
  const TrackingState();
}

class TrackingOffline extends TrackingState {
  const TrackingOffline();
}

class TrackingConnecting extends TrackingState {
  const TrackingConnecting();
}

class TrackingOnline extends TrackingState {
  const TrackingOnline({required this.connection, this.lastMessage});

  final ConnectionStatus connection;
  final String? lastMessage;
}

class TrackingFailed extends TrackingState {
  const TrackingFailed(this.failure);

  final Failure failure;
}

import 'package:freezed_annotation/freezed_annotation.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('assigned')
  assigned,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

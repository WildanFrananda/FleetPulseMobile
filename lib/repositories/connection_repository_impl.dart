import 'package:fleet_pulse_mobile/config/app_config.dart';
import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/driver_session.dart';
import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/telemetry_ping.dart';
import 'package:fleet_pulse_mobile/repositories/connection_repository.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_event.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ConnectionRepository)
class ConnectionRepositoryImpl implements ConnectionRepository {
  ConnectionRepositoryImpl(this._channel);

  final ChannelClient _channel;

  @override
  Stream<ConnectionStatus> get statusStream => _channel.statusStream;

  @override
  Future<void> connect(DriverSession session) =>
      _channel.connect(session, wsBase: AppConfig.wsBase);

  @override
  Future<void> disconnect() => _channel.disconnect();

  @override
  Future<Result<Unit>> sendPing(TelemetryPing ping) async {
    try {
      final ChannelReply reply = await _channel.ping(ping);

      return reply.isOk
          ? const Ok<Unit>(Unit.unit)
          : Err<Unit>(failureFromReason(reply.reason));
    } on ChannelException {
      return const Err<Unit>(NetworkFailure());
    } on Object {
      return const Err<Unit>(NetworkFailure());
    }
  }
}

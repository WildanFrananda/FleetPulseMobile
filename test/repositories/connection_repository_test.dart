import 'dart:async';

import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:fleet_pulse_mobile/repositories/connection_repository_impl.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockChannel extends Mock implements ChannelClient {}

void main() {
  late _MockChannel channel;
  late ConnectionRepositoryImpl sut;

  final TelemetryPing ping = new TelemetryPing(
    latitude: 1,
    longitude: 2,
    recordedAt: DateTime.utc(2026),
  );

  setUpAll(() {
    registerFallbackValue(
      new TelemetryPing(
        latitude: 0,
        longitude: 0,
        recordedAt: DateTime.utc(2026),
      ),
    );
    registerFallbackValue(
      const DriverSession(driverId: DriverId(0), token: ''),
    );
  });

  setUp(() {
    channel = new _MockChannel();
    sut = new ConnectionRepositoryImpl(channel);
  });

  test('sendPing ok maps to Ok', () async {
    when(
      () => channel.ping(any()),
    ).thenAnswer((_) async => const ChannelReply('ok', <String, dynamic>{}));
    expect(await sut.sendPing(ping), isA<Ok<Unit>>());
  });

  test('sendPing error reason maps to ChannelFailure', () async {
    when(() => channel.ping(any())).thenAnswer(
      (_) async => const ChannelReply('error', <String, dynamic>{
        'reason': 'invalid_telemetry',
      }),
    );
    final res = await sut.sendPing(ping);
    expect((res as Err<Unit>).failure, isA<ChannelFailure>());
  });

  test('sendPing ChannelException maps to NetworkFailure', () async {
    when(() => channel.ping(any())).thenThrow(const ChannelException('x'));
    final res = await sut.sendPing(ping);
    expect((res as Err<Unit>).failure, isA<NetworkFailure>());
  });

  test('setStatus ok maps to Ok', () async {
    when(
      () => channel.setStatus(any()),
    ).thenAnswer((_) async => const ChannelReply('ok', <String, dynamic>{}));
    expect(await sut.setStatus('online'), isA<Ok<Unit>>());
  });

  test('statusStream and sessionExpired pass through', () {
    final StreamController<ConnectionStatus> statusCtrl =
        StreamController<ConnectionStatus>.broadcast();
    final StreamController<void> authCtrl = StreamController<void>.broadcast();
    when(() => channel.statusStream).thenAnswer((_) => statusCtrl.stream);
    when(() => channel.unauthorized).thenAnswer((_) => authCtrl.stream);

    expect(sut.statusStream, same(statusCtrl.stream));
    expect(sut.sessionExpired, same(authCtrl.stream));

    unawaited(statusCtrl.close());
    unawaited(authCtrl.close());
  });

  test('onResume triggers reconnectNow', () {
    sut.onResume();
    verify(() => channel.reconnectNow()).called(1);
  });

  test('connect delegates to the channel with a wsBase', () async {
    when(
      () => channel.connect(any(), wsBase: any(named: 'wsBase')),
    ).thenAnswer((_) async {});
    await sut.connect(const DriverSession(driverId: DriverId(1), token: 't'));
    verify(
      () => channel.connect(any(), wsBase: any(named: 'wsBase')),
    ).called(1);
  });
}

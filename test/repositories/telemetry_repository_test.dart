import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:fleet_pulse_mobile/core/core.dart';
import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/telemetry_ping.dart';
import 'package:fleet_pulse_mobile/repositories/telemetry_repository_impl.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_event.dart';
import 'package:fleet_pulse_mobile/services/foreground/foreground_service_manager.dart';
import 'package:fleet_pulse_mobile/services/location/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocation extends Mock implements LocationService {}

class _MockChannel extends Mock implements ChannelClient {}

class _MockForeground extends Mock implements ForegroundServiceManager {}

Position _pos(double lat, double lng) => new Position(
  latitude: lat,
  longitude: lng,
  timestamp: DateTime.utc(2026),
  accuracy: 1,
  altitude: 0,
  altitudeAccuracy: 1,
  heading: 90,
  headingAccuracy: 1,
  speed: 10,
  speedAccuracy: 1,
);

void main() {
  late _MockLocation loc;
  late _MockChannel channel;
  late _MockForeground fg;
  late StreamController<Position> posCtrl;
  late TelemetryRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(
      new TelemetryPing(
        latitude: 0,
        longitude: 0,
        recordedAt: DateTime.utc(2026),
      ),
    );
  });

  setUp(() {
    loc = new _MockLocation();
    channel = new _MockChannel();
    fg = new _MockForeground();
    posCtrl = StreamController<Position>.broadcast();

    when(
      () => loc.ensurePermission(background: any(named: 'background')),
    ).thenAnswer((_) async => LocationPermissionStatus.granted);
    when(() => loc.positions()).thenAnswer((_) => posCtrl.stream);
    when(
      () => channel.ping(any()),
    ).thenAnswer((_) async => const ChannelReply('ok', <String, dynamic>{}));
    when(() => fg.requestPermissions()).thenAnswer((_) async {});
    when(() => fg.start()).thenAnswer((_) async {});
    when(() => fg.stop()).thenAnswer((_) async {});

    sut = TelemetryRepositoryImpl(loc, channel, fg);
  });

  tearDown(() => posCtrl.close());

  test('denied permission returns Err and does not start', () async {
    when(
      () => loc.ensurePermission(background: any(named: 'background')),
    ).thenAnswer((_) async => LocationPermissionStatus.denied);
    final Result<Unit> res = await sut.start();
    expect((res as Err<Unit>).failure, isA<PermissionFailure>());
    expect(sut.isStreaming, isFalse);
    verifyNever(() => fg.start());
  });

  test('sends a ping each cadence while moving', () {
    fakeAsync((async) {
      sut.start().ignore();
      async.flushMicrotasks();
      expect(sut.isStreaming, isTrue);

      posCtrl.add(_pos(-6.20, 106.80));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 4));
      verify(() => channel.ping(any())).called(1);

      posCtrl.add(_pos(-6.30, 106.90));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 4));
      verify(() => channel.ping(any())).called(1);
    });
  });

  test('throttles when stationary', () {
    fakeAsync((async) {
      sut.start().ignore();
      async.flushMicrotasks();

      posCtrl.add(_pos(-6.20, 106.80));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 4));
      verify(() => channel.ping(any())).called(1);

      posCtrl.add(_pos(-6.200001, 106.800001));
      async
        ..flushMicrotasks()
        ..elapse(const Duration(seconds: 4));
      verifyNever(() => channel.ping(any()));
    });
  });

  test('stop halts foreground service and streaming', () async {
    await sut.start();
    expect(sut.isStreaming, isTrue);
    await sut.stop();
    expect(sut.isStreaming, isFalse);
    verify(() => fg.stop()).called(1);
  });
}

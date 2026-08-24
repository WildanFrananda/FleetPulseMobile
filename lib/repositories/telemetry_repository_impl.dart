import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fleet_pulse_mobile/core/failure.dart';
import 'package:fleet_pulse_mobile/core/result.dart';
import 'package:fleet_pulse_mobile/models/enums.dart';
import 'package:fleet_pulse_mobile/models/telemetry_ping.dart';
import 'package:fleet_pulse_mobile/repositories/telemetry_repository.dart';
import 'package:fleet_pulse_mobile/services/channel/channel_client.dart';
import 'package:fleet_pulse_mobile/services/foreground/foreground_service_manager.dart';
import 'package:fleet_pulse_mobile/services/location/location_service.dart';
import 'package:fleet_pulse_mobile/services/offline/hive_telemetry_db.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TelemetryRepository)
class TelemetryRepositoryImpl implements TelemetryRepository {
  TelemetryRepositoryImpl(this._location, this._channel, this._foreground);

  final LocationService _location;
  final ChannelClient _channel;
  final ForegroundServiceManager _foreground;
  final HiveTelemetryDb _offlineDb = new HiveTelemetryDb();

  final StreamController<TelemetryPing> _sendCtrl =
      StreamController<TelemetryPing>.broadcast();

  StreamSubscription<Position>? _posSub;
  Timer? _timer;
  Position? _latest;
  Position? _lastSent;
  bool _streaming = false;

  static const Duration _cadence = Duration(seconds: 4);
  static const double _minMeters = 5;

  @override
  bool get isStreaming => _streaming;

  @override
  Stream<TelemetryPing> get sent => _sendCtrl.stream;

  @override
  Future<void> openAppSettings() => _location.openAppSettings();

  @override
  Future<Result<Unit>> start() async {
    if (_streaming) {
      return const Ok<Unit>(Unit.unit);
    }

    final LocationPermissionStatus perm = await _location.ensurePermission(
      background: true,
    );

    if (perm != LocationPermissionStatus.granted) {
      return Err<Unit>(PermissionFailure(_permMsg(perm)));
    }

    await _foreground.requestPermissions();
    await _foreground.start();

    _posSub = _location.positions().listen((Position p) => _latest = p);
    _timer = Timer.periodic(_cadence, (_) => unawaited(_tick()));
    _streaming = true;

    return const Ok<Unit>(Unit.unit);
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    await _posSub?.cancel();
    await _foreground.stop();

    _posSub = null;
    _latest = null;
    _lastSent = null;
    _streaming = false;
  }

  Future<void> _tick() async {
    final Position? pos = _latest;

    if (pos == null) {
      return;
    }

    final Position? last = _lastSent;

    if (last != null) {
      final double moved = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        pos.latitude,
        pos.longitude,
      );

      if (moved < _minMeters) {
        return;
      }
    }

    final TelemetryPing ping = new TelemetryPing(
      latitude: pos.latitude,
      longitude: pos.longitude,
      recordedAt: clock.now().toUtc(),
      speedKmh: pos.speed >= 0 ? pos.speed * 3.6 : null,
      bearingDeg: (pos.heading >= 0 && pos.heading < 360) ? pos.heading : null,
    );

    _lastSent = pos;
    _sendCtrl.add(ping);

    try {
      await _channel.ping(ping);
      final List<TelemetryPing> queued = await _offlineDb.getQueuedPings();
      if (queued.isNotEmpty) {
        for (final TelemetryPing queuedPing in queued) {
          await _channel.ping(queuedPing);
        }
        await _offlineDb.clearPings(queued.length);
      }
    } on Object {
      await _offlineDb.savePing(ping);
    }
  }

  String _permMsg(LocationPermissionStatus s) => switch (s) {
    LocationPermissionStatus.serviceDisabled => 'location services disabled',
    LocationPermissionStatus.deniedForever =>
      'location permission permanently denied',
    _ => 'location permission denied',
  };

  @override
  @disposeMethod
  Future<void> dispose() async {
    await stop();
    await _sendCtrl.close();
  }
}

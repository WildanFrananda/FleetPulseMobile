import 'dart:async';
import 'package:fleet_pulse_mobile/models/telemetry_ping.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveTelemetryDb {
  static const String _boxName = 'telemetry_offline_pings';
  Box<Map<dynamic, dynamic>>? _box;

  Future<Box<Map<dynamic, dynamic>>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }

    await Hive.initFlutter();
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    return _box!;
  }

  Future<void> savePing(TelemetryPing ping) async {
    try {
      final Box<Map<dynamic, dynamic>> b = await box;
      await b.add(<String, dynamic>{
        'latitude': ping.latitude,
        'longitude': ping.longitude,
        'recorded_at': ping.recordedAt.toIso8601String(),
        'speed_kmh': ping.speedKmh,
        'bearing_deg': ping.bearingDeg,
      });
    } catch (_) {}
  }

  Future<List<TelemetryPing>> getQueuedPings() async {
    try {
      final Box<Map<dynamic, dynamic>> b = await box;
      final List<TelemetryPing> pings = <TelemetryPing>[];

      for (int i = 0; i < b.length; i++) {
        final Map<dynamic, dynamic>? item = b.getAt(i);
        if (item != null) {
          pings.add(
            new TelemetryPing(
              latitude: (item['latitude'] as num).toDouble(),
              longitude: (item['longitude'] as num).toDouble(),
              recordedAt: DateTime.parse(item['recorded_at'] as String),
              speedKmh: item['speed_kmh'] != null
                  ? (item['speed_kmh'] as num).toDouble()
                  : null,
              bearingDeg: item['bearing_deg'] != null
                  ? (item['bearing_deg'] as num).toDouble()
                  : null,
            ),
          );
        }
      }
      return pings;
    } catch (_) {
      return <TelemetryPing>[];
    }
  }

  Future<void> clearPings(int count) async {
    try {
      final Box<Map<dynamic, dynamic>> b = await box;
      final int deleteCount = count < b.length ? count : b.length;
      for (int i = 0; i < deleteCount; i++) {
        await b.deleteAt(0);
      }
    } catch (_) {}
  }
}

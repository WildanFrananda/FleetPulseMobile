import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

@lazySingleton
class LocationService {
  Future<void> openAppSettings() => Geolocator.openAppSettings();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  Future<LocationPermissionStatus> ensurePermission({
    bool background = false,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    final LocationPermissionStatus foreground = switch (perm) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionStatus.granted,
      LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      LocationPermission.denied ||
      LocationPermission.unableToDetermine => LocationPermissionStatus.denied,
    };

    if (foreground != LocationPermissionStatus.granted) {
      return foreground;
    }

    if (background) {
      await ph.Permission.locationAlways.request();
    }

    return LocationPermissionStatus.granted;
  }

  Stream<Position> positions({int distanceFilter = 0}) {
    return Geolocator.getPositionStream(
      locationSettings: _settings(distanceFilter),
    );
  }

  LocationSettings _settings(int distanceFilter) {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
        pauseLocationUpdatesAutomatically: false,
        activityType: ActivityType.automotiveNavigation,
      );
    }

    return new LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );
  }
}

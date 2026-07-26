import 'package:fleet_pulse_mobile/models/models.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';

@lazySingleton
class LocationService {
  Future<LocationPermissionStatus> ensurePersmission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    return switch (perm) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionStatus.granted,
      LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      LocationPermission.denied ||
      LocationPermission.unableToDetermine => LocationPermissionStatus.denied,
    };
  }

  Stream<Position> positions({int distanceFilter = 0}) {
    return Geolocator.getPositionStream(
      locationSettings: new LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }
}

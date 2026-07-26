import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

@lazySingleton
class MapsLauncher {
  Future<bool> openCoordinates(double latitude, double longitude) {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

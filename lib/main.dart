import 'package:fleet_pulse_mobile/di/injection.dart';
import 'package:fleet_pulse_mobile/ui/app.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const FleetPulseApp());
}

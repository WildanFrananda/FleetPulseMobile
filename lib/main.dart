import 'package:fleet_pulse_mobile/di/injection.dart';
import 'package:fleet_pulse_mobile/ui/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const FleetPulseApp());
}

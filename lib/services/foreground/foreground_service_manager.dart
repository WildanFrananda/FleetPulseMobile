import 'dart:io';

import 'package:fleet_pulse_mobile/services/foreground/tracking_task_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ForegroundServiceManager {
  void configure() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'fleetpulse_tracking',
        channelName: 'FleetPulse Tracking',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> requestPermissions() async {
    final NotificationPermission notif =
        await FlutterForegroundTask.checkNotificationPermission();

    if (notif != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid &&
        !await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  Future<void> start() async {
    configure();

    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'FleetPulse Tracking',
      notificationText: 'Sharing your location while on duty',
      callback: startCallback,
    );
  }

  Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

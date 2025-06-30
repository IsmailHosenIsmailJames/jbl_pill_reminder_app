import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/background_task.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<void> requestPermissions() async {
  final NotificationPermission notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermission != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  var ignoreBatteryOpt = await Permission.ignoreBatteryOptimizations.status;
  if (ignoreBatteryOpt != PermissionStatus.granted) {
    ignoreBatteryOpt = await Permission.ignoreBatteryOptimizations.request();
  }

  if (Platform.isAndroid) {
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }
  }
}

Future<void> initService() async {
  final SharedPreferences info = await SharedPreferences.getInstance();
  final timeInterval = info.getInt("time_interval");
  // final minimumDistance = info.getInt("minimum_distance");

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: "foreground_service",
      channelName: "Foreground Service Notification",
      channelDescription:
          "This notification appears when the foreground location service is running.",
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
      eventAction: ForegroundTaskEventAction.repeat(timeInterval ?? 60000),
    ),
  );
}

Future<ServiceRequestResult> startService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: "Foreground Service is running",
      notificationText: "Tap to return to the app",
      notificationIcon: null,
      callback: startCallback,
    );
  }
}

Future<ServiceRequestResult> stopService() async {
  return FlutterForegroundTask.stopService();
}

void onReceiveTaskData(Object data) {
  if (data is int) {
    if (kDebugMode) {
      print("count: $data");
    }
  }
}

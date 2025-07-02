import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/background_task.dart";
import "package:permission_handler/permission_handler.dart";

Future<bool> requestPermissions() async {
  var notificationPermission = await Permission.notification.status;
  if (notificationPermission != PermissionStatus.granted) {
    notificationPermission = await Permission.notification.request();
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
  return notificationPermission == PermissionStatus.granted;
}

Future<void> initService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: "foreground_service",
      channelName: "Foreground Service Notification",
      channelDescription:
          "This notification appears when the foreground location service is running.",
      channelImportance: NotificationChannelImportance.MAX,
      priority: NotificationPriority.MAX,
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
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
      eventAction: ForegroundTaskEventAction.repeat(15000),
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

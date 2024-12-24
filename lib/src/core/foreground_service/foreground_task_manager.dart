import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:jbl_pill_reminder_app/src/core/foreground_service/my_foreground_task_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyForegroundTaskHandler());
}

Future<bool> requestNotificationPermissions() async {
  if (await checkNotificationPermissions() == false) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
  return (await FlutterForegroundTask.checkNotificationPermission()) ==
      NotificationPermission.granted;
}

Future<bool> checkNotificationPermissions() async {
  return (await FlutterForegroundTask.checkNotificationPermission()) ==
      NotificationPermission.granted;
}

Future<bool> isServiceRunning() async {
  return await FlutterForegroundTask.isRunningService;
}

void initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'JBL_Pill_Reminder_App',
      channelName: 'JBL Pill Reminder App Foreground Service',
      channelDescription:
          'This channel is used to notify the user that JBL Pill Reminder App is running in foreground',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(1000),
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

Future<ServiceRequestResult> startService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'JBL Pill Reminder App',
      notificationText: 'Tap to see your medication details',
      callback: startCallback,
    );
  }
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:jbl_pill_reminder_app/src/core/foreground_service/my_foreground_task_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyForegroundTaskHandler());
}

Future<bool> requestPermissions() async {
  if (await checkPermissions() == false) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
  return (await FlutterForegroundTask.checkNotificationPermission()) ==
      NotificationPermission.granted;
}

Future<bool> checkPermissions() async {
  return (await FlutterForegroundTask.checkNotificationPermission()) ==
      NotificationPermission.granted;
}

Future<bool> isServiceRunning() async {
  return await FlutterForegroundTask.isRunningService;
}

void initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
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
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
      notificationButtons: [
        const NotificationButton(id: 'btn_hello', text: 'hello'),
      ],
      notificationInitialRoute: '/second',
      callback: startCallback,
    );
  }
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}

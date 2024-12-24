import 'dart:developer';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jbl_pill_reminder_app/src/core/common.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';

class MyForegroundTaskHandler extends TaskHandler {
  static const String incrementCountCommand = 'incrementCount';
  int count = 0;

  void handleAllBackgroundTask() {
    log(count.toString());
    count++;
    bool isTimeForDemoNotification = DateTime.now().second == 1;
    if (isTimeForDemoNotification) {
      LocalNotifications.flutterLocalNotificationsPlugin.show(
        idForMedication,
        "Take your medicine now!",
        "You have a medication at 12:15 PM. It's time to take it.",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'JBL Pill Reminder',
            channelDescription: 'Notification for JBL Pill Reminder App',
            priority: Priority.max,
          ),
        ),
        payload: "take_medicine",
      );
    }

    // Update notification content.
    FlutterForegroundTask.updateService(
      notificationTitle: "Medication Title at 10:00 AM",
      notificationText: 'You have 3 hours left for next medication.',
    );
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('onStart(starter: ${starter.name})');
    handleAllBackgroundTask();
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    handleAllBackgroundTask();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('onDestroy');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    log('onReceiveData: $data');
    if (data == incrementCountCommand) {
      handleAllBackgroundTask();
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    log('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    log('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    log('onNotificationDismissed');
  }
}

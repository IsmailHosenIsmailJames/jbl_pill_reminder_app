import 'dart:developer';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyForegroundTaskHandler extends TaskHandler {
  static const String incrementCountCommand = 'incrementCount';

  void _incrementCount() {
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
    _incrementCount();
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    _incrementCount();
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
      _incrementCount();
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

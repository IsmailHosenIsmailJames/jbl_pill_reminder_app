import "dart:developer";

import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/callback_dispacher.dart";

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyForegroundTaskHandler());
}

class MyForegroundTaskHandler extends TaskHandler {
  static List<String> foregroundNotification = [];

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    analyzeDatabaseForeground(reloadDB: true);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    log("onRepeatEvent Foreground Task");
    analyzeDatabaseForeground(reloadDB: true);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool success) async {
    log("onDestroy");
  }

  @override
  void onReceiveData(Object data) {
    log("onReceiveData: $data");
  }

  @override
  void onNotificationButtonPressed(String id) {
    log("onNotificationButtonPressed: $id");
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");

    log("onNotificationPressed");
  }

  @override
  void onNotificationDismissed() {
    log("onNotificationDismissed");
  }
}

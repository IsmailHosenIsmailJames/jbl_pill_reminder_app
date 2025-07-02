import "dart:developer";

import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/callback_dispacher.dart";
import "package:shared_preferences/shared_preferences.dart";

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyForegroundTaskHandler());
}

class MyForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    analyzeDatabaseForeground(reloadDB: true);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();

    log([
      sharedPref.get("reminderNotificationShown").toString(),
      sharedPref.get("notificationShown").toString(),
      sharedPref.get("alarmShown").toString()
    ].toString());
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

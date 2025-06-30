import "dart:developer";

import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/schedule_model.dart";

import "../../screens/add_reminder/model/reminder_model.dart";
import "../functions/find_date_medicine.dart";

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  TimeModel? getFirstNextTime(List<TimeModel> listOfTime, DateTime now) {
    listOfTime.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    for (TimeModel time in listOfTime) {
      if (time.hour * 60 + time.minute > now.hour * 60 + now.minute) {
        return time;
      }
    }
    return null;
  }

  ReminderModel? getNextReminder(
      List<ReminderModel> reminderList, DateTime now) {
    log("nextMedicine");

    List<ReminderModel> todaysMedicine = findDateMedicine(reminderList, now);

    Map<int, ReminderModel> todayReminderHave = {};

    for (ReminderModel reminder in todaysMedicine) {
      TimeModel? time = getFirstNextTime(reminder.schedule!.times!, now);
      if (time != null) {
        todayReminderHave.addAll({(time.hour * 60 + time.minute): reminder});
      }
    }
    List<int> timesList = todayReminderHave.keys.toList();
    timesList.sort();

    log(timesList.toString());
    return timesList.isEmpty ? null : todayReminderHave[timesList.first];
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    analyzeDatabaseForeground();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    analyzeDatabaseForeground();
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

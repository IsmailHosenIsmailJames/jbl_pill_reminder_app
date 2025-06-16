import "dart:developer";

import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:jbl_pills_reminder_app/src/core/alarm/alarm_config.dart";
import "package:jbl_pills_reminder_app/src/core/alarm/set_alarm.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/show_notification.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/schedule_model.dart";

import "../../screens/add_reminder/model/reminder_model.dart";
import "../../screens/home/home_screen.dart";
import "../functions/find_date_medicine.dart";

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  void handleTask() async {
    log("onRepeatEvent");
    await Hive.initFlutter();
    await Hive.close();
    final reminderDB = await Hive.openBox("reminder_db");

    List<ReminderModel> allReminder = [];
    for (var element in reminderDB.values) {
      allReminder.add(ReminderModel.fromJson(element));
    }
    allReminder = sortRemindersBasedOnCreatedDate(allReminder);
    List<ReminderModel> todaysReminder = findMedicineForSelectedDay(
        allReminder, DateTime.now().subtract(const Duration(minutes: 5)));
    log("Today's Reminder : ${todaysReminder.length}");
    List<ReminderModel> nextAllReminder = [];

    for (int i = 0; i < todaysReminder.length; i++) {
      log("loop:  $i");
      ReminderModel? nextReminder = getNextReminder(
          todaysReminder, DateTime.now().subtract(const Duration(minutes: 5)));
      if (nextReminder != null) {
        nextAllReminder.add(nextReminder);
      } else {
        break;
      }
      todaysReminder.removeWhere((element) => element.id == nextReminder.id);
    }

    log("Next Reminder : ${nextAllReminder.length}");

    if (nextAllReminder.isNotEmpty) {
      for (int i = 0; i < nextAllReminder.length; i++) {
        log("$i -> ${nextAllReminder[i].id}");
      }
      for (ReminderModel nextReminder in nextAllReminder) {
        List<TimeModel>? times = nextReminder.schedule?.times;

        if (times != null) {
          TimeModel? time = getFirstNextTime(
              times, DateTime.now().subtract(const Duration(minutes: 5)));
          if (time != null) {
            // check for 30 minutes
            int difference = (time.hour * 60 + time.minute) -
                (DateTime.now().hour * 60 + DateTime.now().minute);
            String timeFormatted =
                "${time.name}, ${"${time.hour > 12 ? time.hour % 12 : time.hour}".padLeft(2, '0')}:${"${time.minute}".padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}";
            String fullTrackingID =
                "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${time.id}";

            final actionBox = await Hive.openBox("actions");
            String body = "Your next pill at $timeFormatted";
            String title = "Reminder for ${time.name} medicine";
            log("Difference: $difference");
            if (difference < 30 && difference > 0) {
              Map<String, dynamic> notificationShownMap =
                  Map<String, dynamic>.from(
                      actionBox.get("reminder_shown", defaultValue: {}));
              bool alreadyShown = false;
              log(notificationShownMap.toString());
              if (notificationShownMap.containsKey(fullTrackingID)) {
                alreadyShown = true;
              }
              // push pre reminder notification
              if (!alreadyShown) {
                pushNotifications(
                  id: int.parse(time.id),
                  title: title,
                  body: body,
                  isPreReminder: true,
                );
                notificationShownMap.addAll({
                  fullTrackingID: {
                    "isShown": true,
                    "title": title,
                    "body": "Your next pill at $timeFormatted"
                  }
                });
                await actionBox.put("reminder_shown", notificationShownMap);
              } else {
                log("Already shown ${time.id}");
                FlutterForegroundTask.updateService(
                  notificationTitle: "Pills Reminder",
                  notificationText: "Your next pill at $timeFormatted",
                );
              }
            } else if (difference <= 0 || difference > -5) {
              log("Alarm Time: $difference");
              Map<String, dynamic> alarmShown = Map<String, dynamic>.from(
                  actionBox.get("alarm_shown", defaultValue: {}));
              if (!alarmShown.containsKey(fullTrackingID)) {
                if (nextReminder.reminderType == "notification") {
                  await pushNotifications(
                    id: int.parse(time.id),
                    title: "Time for your medicine!",
                    body:
                        "It's time to take your ${nextReminder.medicine?.genericName ?? nextReminder.medicine?.brandName ?? "medicine"} (${time.name}).",
                    isPreReminder: false,
                  );
                  alarmShown.addAll({
                    fullTrackingID: {
                      "isShown": true,
                      "title": title,
                      "body": "Your next pill at $timeFormatted"
                    }
                  });
                  await actionBox.put("alarm_shown", alarmShown);
                } else {
                  bool status =
                      await checkAndroidScheduleExactAlarmPermission();
                  log("status: $status");
                  if (status == true) {
                    try {
                      log("alarm settings");
                      bool isSuccess = await setAlarm(
                        getAlarmConfig(
                          id: int.parse(time.id),
                          title:
                              "Reminder for ${nextReminder.medicine?.genericName ?? nextReminder.medicine?.brandName ?? "your pills"}",
                          body:
                              "It's time to take your ${time.name} dose.\nMedicine: ${nextReminder.medicine?.genericName ?? nextReminder.medicine?.brandName ?? "your pills"}\nDosage: ${nextReminder.medicine?.strength ?? ""} ${nextReminder.medicine?.strength ?? ""}\nTake it now!.",
                          timeOfAlarm: DateTime.now().copyWith(
                            hour: time.hour,
                            minute: time.minute,
                          ),
                        ),
                      );

                      log("setAlarm -> $isSuccess", name: "Set Alarm");

                      if (isSuccess) {
                        alarmShown.addAll({
                          fullTrackingID: {
                            "isShown": true,
                            "title": title,
                            "body": "Your next pill at $timeFormatted"
                          }
                        });
                      }
                      await actionBox.put("alarm_shown", alarmShown);
                    } catch (e) {
                      log("Error : \n${e.toString()}");
                    }
                  }
                }
              } else {
                log("Already shown ${time.toJson()}");
                FlutterForegroundTask.updateService(
                  notificationTitle: "Pills Reminder",
                  notificationText: "Your next pill at $timeFormatted",
                );
              }
            }
            FlutterForegroundTask.updateService(
              notificationTitle: "Pills Reminder",
              notificationText: "Your next pill at $timeFormatted",
            );
          } else {
            FlutterForegroundTask.updateService(
              notificationTitle: "Foreground Service is running",
              notificationText: "Tap to return to the app",
            );
          }
        } else {
          FlutterForegroundTask.updateService(
            notificationTitle: "Foreground Service is running",
            notificationText: "Tap to return to the app",
          );
        }
      }
    } else {
      FlutterForegroundTask.updateService(
        notificationTitle: "Foreground Service is running",
        notificationText: "Tap to return to the app",
      );
    }
  }

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

  List<ReminderModel> findMedicineForSelectedDay(
      List<ReminderModel> listOfAllReminder, DateTime selectedDay) {
    List<ReminderModel> todaysMedication =
        findDateMedicine(listOfAllReminder, selectedDay);
    List<ReminderModel> listOfTodaysReminder =
        sortRemindersBasedOnCreatedDate(todaysMedication);
    return listOfTodaysReminder;
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    handleTask();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    handleTask();
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

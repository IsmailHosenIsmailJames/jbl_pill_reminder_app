import "dart:developer";

import "package:alarm/alarm.dart";
import "package:awesome_notifications/awesome_notifications.dart";
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/src/core/database/sqlite_helper.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/main.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/schedule_alarm.dart";
import "package:jbl_pills_reminder_app/src/resources/medicine_list.dart";

import "/src/core/functions/find_date_medicine.dart";
import "../notifications/schedule_notification.dart";
import "/src/screens/add_reminder/model/reminder_model.dart";
import "/src/screens/add_reminder/model/schedule_model.dart";
import "/src/screens/home/home_screen.dart" hide findMedicineForSelectedDay;

Future<void> analyzeDatabaseAndScheduleReminder({bool reloadDB = false}) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    log("Notification permissions not granted, skipping background task processing");
    return;
  }
  // Ensure Sqlite is initialized for the foreground task
  await SqliteHelper.initDB();

  final localDb = LocalDbRepository();

  final reminderNotificationShown = await localDb.getPreference("reminderNotificationShown");
  final notificationShown = await localDb.getPreference("notificationShown");
  final alarmShown = await localDb.getPreference("alarmShown");

  log(
    [
      foregroundNotification.toString(),
      reminderNotificationShown.toString(),
      notificationShown.toString(),
      alarmShown.toString(),
    ].toString(),
    name: "onRepeatEvent -> analyzeDatabaseForeground",
  );

  Map<String, String> reminderDataMap = await localDb.getAllReminders();
  List<ReminderModel> allReminder = [];
  for (var element in reminderDataMap.values) {
    allReminder.add(ReminderModel.fromJson(element));
  }
  allReminder = sortRemindersBasedOnCreatedDate(allReminder);
  List<ReminderModel> todaysReminder = findMedicineForSelectedDay(
      allReminder, DateTime.now().subtract(const Duration(minutes: 5)));
  log("analyzeDatabaseForeground -> ${todaysReminder.length}");

  for (ReminderModel reminderModel in todaysReminder) {
    MedicineModel? medicine = reminderModel.medicine;
    if (medicine == null) continue;
    String medicineName = medicine.brandName;
    if (medicineName.isEmpty) medicineName = medicine.genericName;

    List medicineScheduleTimes = reminderModel.schedule?.times ?? [];

    for (TimeModel scheduleTime in medicineScheduleTimes) {
      log("Schedule Medicine : -> ${scheduleTime.toJson()}");
      DateTime now = DateTime.now();
      DateTime timeToShow = DateTime.now()
          .copyWith(hour: scheduleTime.hour, minute: scheduleTime.minute);
      if (timeToShow.hour < now.hour) {
        continue;
      } else if (timeToShow.hour == now.hour) {
        if (timeToShow.minute < now.minute) {
          continue;
        }
      }
      // schedule alarm
      if (reminderModel.reminderType == ReminderType.alarm) {
        int id = scheduleTime.id.toIntOrNull() ?? 0;
        AlarmSettings? alarmSettings = await Alarm.getAlarm(id);
        if (!(alarmSettings != null &&
            alarmSettings.dateTime.hour == scheduleTime.hour &&
            alarmSettings.dateTime.minute == scheduleTime.minute)) {
          await scheduleAlarm(
            id: id,
            title:
                "At ${formatTimeOfDay(TimeOfDay(hour: scheduleTime.hour, minute: scheduleTime.minute))}, Take '$medicineName' Medicine .",
            description: "Don't Miss your scheduled medicine. Take it now.",
            time: DateTime.now().copyWith(
              hour: scheduleTime.hour,
              minute: scheduleTime.minute,
            ),
            data: reminderModel,
          );
        } else {
          log("Already $id scheduled for alarm");
        }
      } else {
        log(scheduleTime.id, name: "Notification ->");
        await scheduleNotification(
          title:
              "At ${formatTimeOfDay(TimeOfDay(hour: scheduleTime.hour, minute: scheduleTime.minute))}, Take '$medicineName' Medicine .",
          body: "Don't Miss your scheduled medicine. Take it now.",
          time: DateTime.now().copyWith(
            hour: scheduleTime.hour,
            minute: scheduleTime.minute,
            second: 0,
          ),
          data: reminderModel,
          isPreReminder: false,
          id: scheduleTime.id.toIntOrNull() ?? 0,
        );
      }

      // schedule notification
      await scheduleNotification(
        id: (scheduleTime.id.toIntOrNull() ?? 0) + 10,
        title:
            "Reminder: You have Medicine '$medicineName' at ${formatTimeOfDay(TimeOfDay(hour: scheduleTime.hour, minute: scheduleTime.minute))}",
        body: "Don't Miss your upcoming medicine. Get ready for take medicine.",
        time: DateTime.now()
            .copyWith(
              hour: scheduleTime.hour,
              minute: scheduleTime.minute,
              second: 0,
            )
            .subtract(const Duration(minutes: 15)),
        isPreReminder: true,
      );
    }
  }

  log("Finished Task");
}

String formatTimeOfDay(TimeOfDay timeOfDay) {
  bool isPM = timeOfDay.hour >= 12;

  int hour = timeOfDay.hour % 12;
  if (hour == 0) {
    hour = 12;
  }
  return "${hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')} ${isPM ? "PM" : "AM"}";
}

Future<void> cancelAllScheduledTask() async {
  await Alarm.stopAll();
  await AwesomeNotifications().cancelAll();
}

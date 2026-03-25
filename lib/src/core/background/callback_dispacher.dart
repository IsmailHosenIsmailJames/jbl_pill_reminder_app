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

import "../functions/find_date_medicine.dart";
import "../notifications/schedule_notification.dart";
import "../../screens/add_reminder/model/reminder_model.dart";
import "../../screens/add_reminder/model/schedule_model.dart";

/// Large offset to separate pre-reminder IDs from main notification IDs,
/// preventing collisions when schedules have sequential base IDs.
const int _preReminderIdOffset = 100000;

Future<void> analyzeDatabaseAndScheduleReminder(
    {bool reloadDB = false}) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    log("Notification permissions not granted, skipping background task processing");
    return;
  }

  // Ensure Sqlite is initialized (needed in background isolate)
  await SqliteHelper.initDB();

  final localDb = LocalDbRepository();

  final reminderNotificationShown =
      await localDb.getPreference("reminderNotificationShown");
  final notificationShown =
      await localDb.getPreference("notificationShown");
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
    try {
      allReminder.add(ReminderModel.fromJson(element));
    } catch (e) {
      log("Error parsing reminder: $e");
    }
  }
  allReminder = sortRemindersBasedOnCreatedDate(allReminder);
  List<ReminderModel> todaysReminder = findMedicineForSelectedDay(
      allReminder, DateTime.now().subtract(const Duration(minutes: 5)));
  log("analyzeDatabaseForeground -> ${todaysReminder.length} reminders for today");

  final DateTime now = DateTime.now();

  for (ReminderModel reminderModel in todaysReminder) {
    MedicineModel? medicine = reminderModel.medicine;
    if (medicine == null) continue;
    String medicineName = medicine.brandName;
    if (medicineName.isEmpty) medicineName = medicine.genericName;

    List medicineScheduleTimes = reminderModel.schedule?.times ?? [];

    for (TimeModel scheduleTime in medicineScheduleTimes) {
      log("Schedule Medicine : -> ${scheduleTime.toJson()}");

      DateTime timeToShow = DateTime(
        now.year,
        now.month,
        now.day,
        scheduleTime.hour,
        scheduleTime.minute,
      );

      // Skip if the scheduled time has already passed
      if (timeToShow.isBefore(now)) {
        log("Skipping past schedule: ${scheduleTime.toJson()}");
        continue;
      }

      final String formattedTime = formatTimeOfDay(
          TimeOfDay(hour: scheduleTime.hour, minute: scheduleTime.minute));

      // Schedule alarm or notification for the main reminder
      if (reminderModel.reminderType == ReminderType.alarm) {
        int id = scheduleTime.id.toIntOrNull() ?? 0;
        AlarmSettings? alarmSettings = await Alarm.getAlarm(id);
        if (!(alarmSettings != null &&
            alarmSettings.dateTime.hour == scheduleTime.hour &&
            alarmSettings.dateTime.minute == scheduleTime.minute)) {
          await scheduleAlarm(
            id: id,
            title:
                "At $formattedTime, Take '$medicineName' Medicine .",
            description: "Don't Miss your scheduled medicine. Take it now.",
            time: timeToShow,
            data: reminderModel,
          );
        } else {
          log("Already $id scheduled for alarm");
        }
      } else {
        log(scheduleTime.id, name: "Notification ->");
        await scheduleNotification(
          title:
              "At $formattedTime, Take '$medicineName' Medicine .",
          body: "Don't Miss your scheduled medicine. Take it now.",
          time: timeToShow,
          data: reminderModel,
          isPreReminder: false,
          id: scheduleTime.id.toIntOrNull() ?? 0,
        );
      }

      // Schedule a pre-reminder 15 minutes before
      // Use a large offset to avoid ID collisions with the main notification
      final DateTime preReminderTime =
          timeToShow.subtract(const Duration(minutes: 15));

      if (preReminderTime.isAfter(now)) {
        await scheduleNotification(
          id: (scheduleTime.id.toIntOrNull() ?? 0) + _preReminderIdOffset,
          title:
              "Reminder: You have Medicine '$medicineName' at $formattedTime",
          body:
              "Don't Miss your upcoming medicine. Get ready for take medicine.",
          time: preReminderTime,
          isPreReminder: true,
        );
      } else {
        log("Skipping pre-reminder — time already passed: ${preReminderTime.toIso8601String()}");
      }
    }
  }

  log("Finished scheduling task");
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

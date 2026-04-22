import "dart:convert";
import "dart:developer";

import "package:alarm/alarm.dart";
import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/src/core/database/sqlite_helper.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/schedule_alarm.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/data/models/pill_schedule_model.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_enums.dart";

import "../functions/find_date_medicine.dart";
import "../notifications/schedule_notification.dart";

/// Large offset to separate pre-reminder IDs from main notification IDs,
/// preventing collisions when schedules have sequential base IDs.
const int _preReminderIdOffset = 100000;

Future<void> analyzeDatabaseAndScheduleReminder({bool reloadDB = false}) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    log("Notification permissions not granted, skipping background task processing");
    return;
  }

  // Ensure Sqlite is initialized (needed in background isolate)
  await SqliteHelper.initDB();

  final localDb = LocalDbRepository();

  Map<String, String> reminderDataMap = await localDb.getAllReminders();
  List<PillScheduleEntity> allSchedules = [];
  for (var element in reminderDataMap.values) {
    try {
      final map = Map<String, dynamic>.from(jsonDecode(element));
      allSchedules.add(PillScheduleModel.fromJson(map));
    } catch (e) {
      log("Error parsing schedule: $e");
    }
  }

  List<PillScheduleEntity> todaysSchedules = findMedicineForSelectedDay(
      allSchedules, DateTime.now().subtract(const Duration(minutes: 5)));
  log("analyzeDatabaseForeground -> ${todaysSchedules.length} schedules for today");

  final DateTime now = DateTime.now();

  for (PillScheduleEntity schedule in todaysSchedules) {
    String medicineName = schedule.medicineName;
    List<ScheduleTimeSlot> timeSlots = schedule.times ?? [];

    for (int i = 0; i < timeSlots.length; i++) {
      final slot = timeSlots[i];
      String timeStr = "";
      switch (slot) {
        case ScheduleTimeSlot.Morning:
          timeStr = schedule.morningTime;
          break;
        case ScheduleTimeSlot.Afternoon:
          timeStr = schedule.afternoonTime;
          break;
        case ScheduleTimeSlot.Evening:
          timeStr = schedule.eveningTime;
          break;
        case ScheduleTimeSlot.Night:
          timeStr = schedule.nightTime;
          break;
      }

      if (timeStr.isEmpty) continue;

      final parts = timeStr.split(":");
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : "0") ?? 0;

      DateTime timeToShow = DateTime(now.year, now.month, now.day, hour, minute);

      // Skip if the scheduled time has already passed
      if (timeToShow.isBefore(now)) {
        log("Skipping past schedule: ${slot.name} at $timeStr");
        continue;
      }

      final String formattedTime = formatTimeOfDay(TimeOfDay(hour: hour, minute: minute));

      // Use a deterministic ID based on schedule id and slot index
      int notificationId = (schedule.id?.hashCode ?? 0).abs() % 90000 + i;

      // Schedule alarm or notification for the main reminder
      if (schedule.reminderType == ReminderType.alarm) {
        AlarmSettings? alarmSettings = await Alarm.getAlarm(notificationId);
        if (!(alarmSettings != null &&
            alarmSettings.dateTime.hour == hour &&
            alarmSettings.dateTime.minute == minute)) {
          await scheduleAlarm(
            id: notificationId,
            title: "At $formattedTime, Take '$medicineName' Medicine .",
            description: "Don't Miss your scheduled medicine. Take it now.",
            time: timeToShow,
          );
        } else {
          log("Already $notificationId scheduled for alarm");
        }
      } else {
        log("$notificationId", name: "Notification ->");
        await scheduleNotification(
          title: "At $formattedTime, Take '$medicineName' Medicine .",
          body: "Don't Miss your scheduled medicine. Take it now.",
          time: timeToShow,
          isPreReminder: false,
          id: notificationId,
          payloadData: jsonEncode({"medicineName": medicineName, "id": schedule.id}),
        );
      }

      // Schedule a pre-reminder 15 minutes before
      final DateTime preReminderTime = timeToShow.subtract(const Duration(minutes: 15));

      if (preReminderTime.isAfter(now)) {
        await scheduleNotification(
          id: notificationId + _preReminderIdOffset,
          title: "Reminder: You have Medicine '$medicineName' at $formattedTime",
          body: "Don't Miss your upcoming medicine. Get ready for take medicine.",
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

/// Cancels all scheduled notifications and alarms for a specific schedule.
Future<void> cancelNotificationsForSchedule(PillScheduleEntity schedule) async {
  final times = schedule.times ?? [];
  for (int i = 0; i < times.length; i++) {
    final int id = (schedule.id?.hashCode ?? 0).abs() % 90000 + i;
    final int preReminderId = id + _preReminderIdOffset;

    if (schedule.reminderType == ReminderType.alarm) {
      await Alarm.stop(id);
    }
    // Always cancel awesome_notifications entries (main + pre-reminder)
    await AwesomeNotifications().cancel(id);
    await AwesomeNotifications().cancel(preReminderId);
  }
}


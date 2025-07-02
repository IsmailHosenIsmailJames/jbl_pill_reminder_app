import "dart:developer";

import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/background_task.dart";

import "/src/core/functions/find_date_medicine.dart";
import "/src/core/notifications/show_notification.dart";
import "/src/screens/add_reminder/model/reminder_model.dart";
import "/src/screens/add_reminder/model/schedule_model.dart";
import "/src/screens/home/home_screen.dart" hide findMedicineForSelectedDay;

Future<void> analyzeDatabaseForeground({bool reloadDB = false}) async {
  // Ensure Hive is initialized for the foreground task
  await Hive.initFlutter();

  if (reloadDB) {
    await Hive.close();
    await Hive.initFlutter();
    if (Hive.isBoxOpen("reminder_db")) {
      await Hive.box("reminder_db").close();
      await Hive.openBox("reminder_db");
    }
  }

  final notificationBox = await Hive.openBox("notificationHistory");

  log(
    [
      MyForegroundTaskHandler.foregroundNotification.toString(),
      notificationBox.get("reminderNotificationShown").toString(),
      notificationBox.get("notificationShown").toString(),
      notificationBox.get("alarmShown").toString(),
    ].toString(),
    name: "onRepeatEvent -> analyzeDatabaseForeground",
  );

  List<String> reminderNotificationShown =
      notificationBox.get("reminderNotificationShown") ?? [];
  List<String> notificationShown =
      notificationBox.get("notificationShown") ?? [];
  List<String> alarmShown = notificationBox.get("alarmShown") ?? [];

  final reminderDB = await Hive.openBox("reminder_db");
  List<ReminderModel> allReminder = [];
  for (var element in reminderDB.values) {
    allReminder.add(ReminderModel.fromJson(element));
  }
  allReminder = sortRemindersBasedOnCreatedDate(allReminder);
  List<ReminderModel> todaysReminder = findMedicineForSelectedDay(
      allReminder, DateTime.now().subtract(const Duration(minutes: 5)));
  List<ReminderModel> upcomingRemindersInNext15Min = [];
  DateTime now = DateTime.now();
  DateTime fifteenMinutesFromNow = now.add(const Duration(minutes: 15));
  log("analyzeDatabaseForeground -> ${todaysReminder.length}");

  for (ReminderModel reminderModel in todaysReminder) {
    for (TimeModel timeModel in reminderModel.schedule?.times ?? []) {
      int idAsInt = int.parse(timeModel.id);
      String uniqueId =
          "${DateFormat("yyyyMMdd").format(DateTime.now())}_$idAsInt";
      DateTime exactMedicationTime = now.copyWith(
        hour: timeModel.hour,
        minute: timeModel.minute,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

      DateTime preReminderTime =
          exactMedicationTime.subtract(const Duration(minutes: 15));
      // check time difference less then 1 minute
      // reminder notification before actual [exactMedicationTime] notification or alarm
      // it will show 15 minutes early.
      // difference between [preReminderTime]
      Duration durationDiff = preReminderTime.difference(now);
      if (durationDiff.inMinutes.abs() <= 15 &&
          now.isBefore(exactMedicationTime)) {
        if (!upcomingRemindersInNext15Min
            .any((r) => r.id == reminderModel.id)) {
          upcomingRemindersInNext15Min.add(reminderModel);
        }

        log(
            upcomingRemindersInNext15Min.length.toString() +
                upcomingRemindersInNext15Min.toString(),
            name: "UPCN");

        if (!reminderNotificationShown.contains(uniqueId)) {
          reminderNotificationShown.add(uniqueId);
          await notificationBox.put(
              "reminderNotificationShown", reminderNotificationShown);
          await pushNotifications(
            id: idAsInt,
            title:
                "Pre-Reminder: ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"}",
            body:
                "You have a dose of ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"} scheduled in 15 minutes.",
            isPreReminder: true,
            data: reminderModel,
            isAlarm: false,
          );
        } else {
          log("Already Shown $idAsInt", name: "pre_reminder");
        }
      }

      if (now.isAfter(exactMedicationTime) &&
          now.difference(exactMedicationTime).inMinutes <= 15) {
        String title =
            "It's time for take ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "medicine"}";
        String body =
            "Time for ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "take medicine"}";

        // check if the time difference is less then 1 minute

        if (reminderModel.reminderType == ReminderType.alarm) {
          if (!alarmShown.contains(uniqueId)) {
            alarmShown.add(uniqueId);
            await notificationBox.put("alarmShown", alarmShown);

            await pushNotifications(
              id: idAsInt,
              title: title,
              body: body,
              isPreReminder: false,
              data: reminderModel,
              isAlarm: true,
            );
          } else {
            log("Already Shown $idAsInt", name: "alarm");
          }
        } else {
          if (!notificationShown.contains(uniqueId)) {
            notificationShown.add(uniqueId);
            await notificationBox.put("notificationShown", notificationShown);

            await pushNotifications(
              id: idAsInt,
              title: title,
              body: body,
              isPreReminder: false,
              data: reminderModel,
              isAlarm: false,
            );
          } else {
            log("Already Shown $idAsInt", name: "reminder");
          }
        }
      }
    }
  }
  if (upcomingRemindersInNext15Min.isNotEmpty) {
    log("I am not Empty -> ${upcomingRemindersInNext15Min.length}",
        name: "XYZ");
    try {
      String title;
      String body;
      if (upcomingRemindersInNext15Min.length == 1) {
        var reminderModel = upcomingRemindersInNext15Min.first;
        title =
            "Pre-Reminder: ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"}";
        body =
            "You have a dose of ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"} scheduled in 15 minutes.";
      } else {
        // more info
        title = "Upcoming Medications Reminder";
        body =
            "You have ${upcomingRemindersInNext15Min.length} medications scheduled in the next 15 minutes.";
        // List all upcoming medications
        String medicationList = upcomingRemindersInNext15Min
            .map((reminder) =>
                reminder.medicine?.brandName ??
                reminder.medicine?.genericName ??
                "Unknown Medicine")
            .join(", ");
        body += " Medications: $medicationList.";
      }
      bool isSetBefore = true;
      for (ReminderModel model in upcomingRemindersInNext15Min) {
        String uniqueId =
            "${DateFormat("yyyyMMdd").format(DateTime.now())}_${model.id}";
        if (!MyForegroundTaskHandler.foregroundNotification
            .contains(uniqueId)) {
          isSetBefore = false;
          MyForegroundTaskHandler.foregroundNotification.add(uniqueId);
        }
      }
      if (!isSetBefore) {
        FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: body,
        );
      }
    } catch (e) {
      log(e.toString(), name: "upcomingRemindersInNext15Min");
    }
  } else {
    FlutterForegroundTask.updateService(
      notificationTitle: "Foreground Service is running",
      notificationText: "Tap to return to the app",
    );
  }

  log("Finished Task");
}

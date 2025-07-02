import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";

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

  SharedPreferences sharedPref = await SharedPreferences.getInstance();

  List<String> reminderNotificationShown =
      sharedPref.getStringList("reminderNotificationShown") ?? [];
  List<String> notificationShown =
      sharedPref.getStringList("notificationShown") ?? [];
  List<String> alarmShown = sharedPref.getStringList("alarmShown") ?? [];

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
      DateTime exactMedicationTime = now.copyWith(
          hour: timeModel.hour,
          minute: timeModel.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0);

      DateTime preReminderTime =
          exactMedicationTime.subtract(const Duration(minutes: 15));
      log(exactMedicationTime.difference(now).inSeconds.abs().toString());
      // check time difference less then 1 minute
      if (preReminderTime.difference(now).inSeconds.abs() <= 60) {
        if (!reminderNotificationShown.contains(idAsInt.toString())) {
          reminderNotificationShown.add(idAsInt.toString());
          await sharedPref.setStringList(
              "reminderNotificationShown", reminderNotificationShown);
          await AwesomeNotifications().dismiss(idAsInt);
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

      if (exactMedicationTime.isBefore(fifteenMinutesFromNow)) {
        // To avoid adding the same reminder multiple times if it has multiple schedules in the next 15 mins
        if (!upcomingRemindersInNext15Min
            .any((r) => r.id == reminderModel.id)) {
          upcomingRemindersInNext15Min.add(reminderModel);
        }
      }

      if (exactMedicationTime.difference(now).inSeconds.abs() <= 60) {
        String title =
            "It's time for take ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "medicine"}";
        String body =
            "Time for ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "take medicine"}";

        // check if the time difference is less then 1 minute

        if (reminderModel.reminderType == ReminderType.alarm) {
          if (!alarmShown.contains(idAsInt.toString())) {
            alarmShown.add(idAsInt.toString());
            await sharedPref.setStringList("alarmShown", alarmShown);

            await AwesomeNotifications().dismiss(idAsInt);
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
          if (!notificationShown.contains(idAsInt.toString())) {
            notificationShown.add(idAsInt.toString());
            await sharedPref.setStringList(
                "notificationShown", notificationShown);

            await AwesomeNotifications().dismiss(idAsInt);
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
    for (var reminderModel in upcomingRemindersInNext15Min) {
      try {
        String title =
            "Pre-Reminder: ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"}";
        String body =
            "You have a dose of ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"} scheduled in 15 minutes.";
        FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: body,
        );
      } catch (e) {
        log(e.toString(), name: "upcomingRemindersInNext15Min");
      }
    }
  } else {
    FlutterForegroundTask.updateService(
      notificationTitle: "Foreground Service is running",
      notificationText: "Tap to return to the app",
    );
  }

  log("Finished Task");
}

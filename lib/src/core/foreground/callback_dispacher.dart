import "dart:developer";

import "package:alarm/alarm.dart";
import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:hive_flutter/hive_flutter.dart";

import "/src/core/alarm/alarm_config.dart";
import "/src/core/alarm/set_alarm.dart";
import "/src/core/functions/find_date_medicine.dart";
import "/src/core/notifications/show_notification.dart";
import "/src/screens/add_reminder/model/reminder_model.dart";
import "/src/screens/add_reminder/model/schedule_model.dart";
import "/src/screens/home/home_screen.dart" hide findMedicineForSelectedDay;

Future<void> analyzeDatabaseForeground() async {
  await Alarm.init();
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
  List<ReminderModel> upcomingRemindersInNext15Min = [];
  DateTime now = DateTime.now();
  DateTime fifteenMinutesFromNow = now.add(const Duration(minutes: 15));

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
      if (preReminderTime.isAfter(now)) {
        await pushNotifications(
          id: idAsInt,
          title:
              "Pre-Reminder: ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"}",
          body:
              "You have a dose of ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"} scheduled in 15 minutes.",
          time: preReminderTime,
          isPreReminder: true,
          data: reminderModel,
        );
      }

      if (exactMedicationTime.isAfter(now) &&
          exactMedicationTime.isBefore(fifteenMinutesFromNow)) {
        // To avoid adding the same reminder multiple times if it has multiple schedules in the next 15 mins
        if (!upcomingRemindersInNext15Min
            .any((r) => r.id == reminderModel.id)) {
          upcomingRemindersInNext15Min.add(reminderModel);
        }
      }

      if (exactMedicationTime.isAfter(now)) {
        String title =
            "It's time for take ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "medicine"}";
        String body =
            "Time for ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "take medicine"}";
        if (reminderModel.reminderType == ReminderType.alarm) {
          AlarmSettings? previousConfig = await Alarm.getAlarm(idAsInt);
          if (previousConfig == null) {
            await setAlarm(getAlarmConfig(
              id: idAsInt,
              timeOfAlarm: exactMedicationTime,
              title: title,
              body: body,
              data: reminderModel,
            ));
          } else {
            print("Already alarm set");
          }
        } else {
          await pushNotifications(
            id: idAsInt,
            title: title,
            body: body,
            time: exactMedicationTime,
            isPreReminder: false,
            data: reminderModel,
          );
        }
      }
    }
  }

  if (upcomingRemindersInNext15Min.isNotEmpty) {
    for (var reminderModel in upcomingRemindersInNext15Min) {
      try {
        FlutterForegroundTask.updateService(
          notificationTitle:
              "Pre-Reminder: ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"}",
          notificationText:
              "You have a dose of ${reminderModel.medicine?.brandName ?? reminderModel.medicine?.genericName ?? "Take medicine"} scheduled in 15 minutes.",
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

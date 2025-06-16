import "dart:developer";

import "package:alarm/alarm.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:workmanager/workmanager.dart";

import "/src/core/alarm/alarm_config.dart";
import "/src/core/alarm/set_alarm.dart";
import "/src/core/functions/find_date_medicine.dart";
import "/src/core/notifications/show_notification.dart";
import "/src/screens/add_reminder/model/reminder_model.dart";
import "/src/screens/add_reminder/model/schedule_model.dart";
import "/src/screens/home/home_screen.dart" hide findMedicineForSelectedDay;

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await analyzeDatabase();
    return Future.value(true);
  });
}

Future<void> analyzeDatabase() async {
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
  DateTime now = DateTime.now();
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
              "Pre-Reminder: ${reminderModel.medicine?.genericName ?? reminderModel.medicine?.brandName ?? "Take medicine"}",
          body:
              "You have a dose of ${reminderModel.medicine?.genericName ?? reminderModel.medicine?.brandName ?? "Take medicine"} scheduled in 15 minutes.",
          time: preReminderTime,
          isPreReminder: true,
          data: reminderModel,
        );
      }

      if (exactMedicationTime.isAfter(now)) {
        String title =
            "It's time for take ${reminderModel.medicine?.genericName ?? reminderModel.medicine?.brandName ?? "medicine"}";
        String body =
            "Time for ${reminderModel.medicine?.genericName ?? reminderModel.medicine?.brandName ?? "take medicine"}";
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
  log("Finished Task");
}

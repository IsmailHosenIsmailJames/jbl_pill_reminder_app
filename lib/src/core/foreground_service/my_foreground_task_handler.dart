import 'dart:convert';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/core/common.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/schedule_model.dart';
import 'package:jbl_pill_reminder_app/src/resources/keys.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/add_alarm_times.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';
import 'package:intl/intl.dart' as intl;

class MyForegroundTaskHandler extends TaskHandler {
  static const String incrementCountCommand = 'incrementCount';

  void handleAllBackgroundTask() async {
    log('handleAllBackgroundTask');
    try {
      await SharedPrefs.init();
      await SharedPrefs.prefs.reload();
      List<String>? allMedication =
          SharedPrefs.prefs.getStringList(allMedicationKey);
      log("allMedication: ${allMedication?.length}");

      if (allMedication == null || allMedication.isEmpty) {
        log("Returning as allMedication is null or empty");
        FlutterForegroundTask.updateService(
          notificationTitle: "Add medicine to remind you",
          notificationText:
              "You have a empty medication list. Add medicine to remind you.",
        );
        return;
      }

      String? medicineTokenTime =
          SharedPrefs.prefs.getString(medicineTokenTimeKey);

      log("Going to loop");

      Map<String, dynamic> medicineTokenTimeMap = <String, dynamic>{};
      medicineTokenTimeMap = jsonDecode(medicineTokenTime ?? "{}");

      for (var medication in allMedication) {
        final medicationModel = MedicationModel.fromJson(medication);
        ScheduleModel? scheduleModel = medicationModel.schedule;
        String medicationTitle = medicationModel.title!;
        if (medicineTokenTimeMap
            .containsKey(intl.DateFormat("dd-mm-yy").format(DateTime.now()))) {
          Map todayData = medicineTokenTimeMap[
              intl.DateFormat("dd-mm-yy").format(DateTime.now())];
          if (todayData.containsKey(medicationModel.id)) {
            return;
          }
        }
        if (scheduleModel != null) {
          bool isTodayHaveMedication =
              checkIfTodayHaveMedication(scheduleModel);
          if (isTodayHaveMedication) {
            log("Today there is medication");
            // check the time and show notification. Notification will start showing before 30 mins and every 5 mins until the time arrived or medicine taken.
            scheduleModel.times?.forEach((time) {
              DateTime now = DateTime.now();
              TimeOfDay alarmClock = clockFormat(time.clock!);
              DateTime alarmTime = DateTime(now.year, now.month, now.day,
                  alarmClock.hour, alarmClock.minute);
              int minutesDifference = now.difference(alarmTime).inMinutes.abs();
              log('minutesDifference: $minutesDifference');
              if (now.millisecondsSinceEpoch >
                  alarmTime.millisecondsSinceEpoch) {
                minutesDifference = minutesDifference * -1;
              }
              log(minutesDifference.toString());

              String alarmOrNotification = time.notificationType ?? "alarm";
              log("Going to tiger Alarm");
              Alarm.set(
                alarmSettings: AlarmSettings(
                  id: alarmIDforMedicationReminder,
                  dateTime: DateTime.now().add(const Duration(seconds: 5)),
                  assetAudioPath: "assets/shaking-pill-bottle.mp3",
                  loopAudio: true,
                  vibrate: true,
                  androidFullScreenIntent: true,
                  notificationSettings: NotificationSettings(
                    title:
                        "$medicationTitle at ${formatClockWithoutContext(alarmClock)}",
                    body:
                        "It's time to take $medicationTitle's medicines. Please Take your medicine",
                  ),
                ),
              );

              if (minutesDifference.abs() <= 30) {
                String notificationType = "reminder";
                String notificationTitle =
                    "Your next medicine \"$medicationTitle\" is at ${formatClockWithoutContext(clockFormat(time.clock!))}";
                String subTitle =
                    "You have $minutesDifference minutes left for next medication. Tap to see details.";
                if (minutesDifference < 0 && minutesDifference >= -5) {
                  notificationType = "take_now";
                  notificationTitle =
                      "It's time to take \"$medicationTitle\" medicine.";
                  subTitle =
                      "Please take your medicine now. Tap to see details.";
                }
                String infoPath =
                    "$notificationType${medicationModel.id}${time.id}";
                String? isNotificationShown =
                    SharedPrefs.prefs.getString(infoPath);
                FlutterForegroundTask.updateService(
                  notificationTitle:
                      "$medicationTitle at ${formatClockWithoutContext(clockFormat(time.clock!))}",
                  notificationText: subTitle,
                );

                if (isNotificationShown == null) {
                  if (notificationType == "take_now" &&
                      alarmOrNotification == "alarm") {
                    Alarm.set(
                      alarmSettings: AlarmSettings(
                        id: alarmIDforMedicationReminder,
                        dateTime:
                            DateTime.now().add(const Duration(seconds: 5)),
                        assetAudioPath: "assets/shaking-pill-bottle.mp3",
                        loopAudio: true,
                        vibrate: true,
                        androidFullScreenIntent: true,
                        notificationSettings: NotificationSettings(
                          title:
                              "$medicationTitle at ${formatClockWithoutContext(alarmClock)}",
                          body:
                              "It's time to take $medicationTitle's medicines. Please Take your medicine",
                        ),
                      ),
                    );
                  } else {
                    LocalNotifications.flutterLocalNotificationsPlugin.show(
                      idForMedication,
                      notificationTitle,
                      subTitle,
                      const NotificationDetails(
                        android: AndroidNotificationDetails(
                          notificationChannelId,
                          'JBL Pill Reminder',
                          channelDescription:
                              'Notification for JBL Pill Reminder App',
                          priority: Priority.max,
                        ),
                      ),
                      payload: "take_medicine",
                    );
                  }

                  SharedPrefs.prefs.setString(infoPath, "true");
                }

                if (minutesDifference >= 0) {
                  FlutterForegroundTask.updateService(
                    notificationTitle:
                        "$medicationTitle at ${formatClockWithoutContext(clockFormat(time.clock!))}",
                    notificationText:
                        'You have ${minutesDifference.abs()} minutes left for next medication.',
                  );
                } else {
                  FlutterForegroundTask.updateService(
                    notificationTitle:
                        "$medicationTitle at ${formatClockWithoutContext(clockFormat(time.clock!))}",
                    notificationText:
                        'You missed your medicine that was needed to take ${minutesDifference.abs()} minutes earlier. Take it now.',
                  );
                }
              } else {
                SharedPrefs.prefs
                    .remove("take_now${medicationModel.id}${time.id}");

                SharedPrefs.prefs
                    .remove("reminder${medicationModel.id}${time.id}");

                int distanceMins = now.difference(alarmTime).inMinutes.abs();
                log("distanceMins: $distanceMins");
                if (now.millisecondsSinceEpoch >
                    alarmTime.millisecondsSinceEpoch) {
                  distanceMins = distanceMins * -1;
                }
                log("distanceMins: $distanceMins");

                if (distanceMins >= 0) {
                  FlutterForegroundTask.updateService(
                    notificationTitle:
                        "$medicationTitle at ${formatClockWithoutContext(clockFormat(time.clock!))}",
                    notificationText:
                        'Your next medicine have ${formatDuration(Duration(minutes: distanceMins))} time left.',
                  );
                } else {
                  FlutterForegroundTask.updateService(
                    notificationTitle:
                        "$medicationTitle at ${formatClockWithoutContext(clockFormat(time.clock!))}",
                    notificationText:
                        'Your missed medicine was at ${formatClockWithoutContext(clockFormat(time.clock!))}, ${intl.DateFormat.yMMMd().format(alarmTime)}.',
                  );
                }
              }
            });
          } else {
            FlutterForegroundTask.updateService(
              notificationTitle: "Today there have no medicine to take",
              notificationText:
                  "According to medication schedules, today there have no medicine to take.",
            );
            log("There have no medicine to take");
          }
        } else {
          continue;
        }
      }
    } catch (e) {
      log(e.toString());
      return;
    }
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('onStart(starter: ${starter.name})');
    handleAllBackgroundTask();
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    handleAllBackgroundTask();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    log('onDestroy');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    log('onReceiveData: $data');
    if (data == incrementCountCommand) {
      handleAllBackgroundTask();
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    log('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    log('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    log('onNotificationDismissed');
  }
}

bool checkIfTodayHaveMedication(ScheduleModel schedule) {
  DateTime startDate = schedule.startDate;
  DateTime? endDate = schedule.endDate!;

  if (DateTime.now().millisecondsSinceEpoch >=
          startDate.millisecondsSinceEpoch &&
      DateTime.now().millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch) {
    log("Medication is active");

    if (schedule.frequency?.type == frequencyTypeList[0]) {
      return true;
    } else if (schedule.frequency?.type == frequencyTypeList[1]) {
      int? distance = schedule.frequency?.everyXDays;
      DateTime startDate = schedule.startDate;
      DateTime date = DateTime.now();
      date = DateTime(date.year, date.month, date.day);
      int difference = date.difference(startDate).inDays;
      if (distance != null && difference % distance == 0) {
        return true;
      } else {
        return false;
      }
    } else if (schedule.frequency?.type == frequencyTypeList[2]) {
      List<String> listOfDay = (schedule.frequency?.weekly?.days) ?? [];
      log(schedule.frequency?.weekly?.days.toString() ?? "",
          name: "checkIfTodayHaveMedication");
      log(weekDaysList[DateTime.now().weekday - 1].toString(),
          name: "checkIfTodayHaveMedication");
      if (listOfDay.contains(weekDaysList[DateTime.now().weekday - 1])) {
        return true;
      } else {
        return false;
      }
    } else if (schedule.frequency?.type == frequencyTypeList[3]) {
      List<int> listOfDay = (schedule.frequency?.monthly?.dates) ?? [];
      if (listOfDay.contains(DateTime.now().day)) {
        return true;
      } else {
        return false;
      }
    } else if (schedule.frequency?.type == frequencyTypeList[4]) {
      List<DateTime> listOfDay = (schedule.frequency?.yearly?.dates) ?? [];
      for (var element in listOfDay) {
        if (element.day == DateTime.now().day &&
            element.month == DateTime.now().month &&
            element.year == DateTime.now().year) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

String formatClockWithoutContext(TimeOfDay time) {
  if (time.hour > 12) {
    return "${(time.hour - 12).toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} PM";
  } else {
    return "${time.hour}:${time.minute} AM";
  }
}

String formatDuration(Duration duration) {
  return "${duration.inHours}:${duration.inMinutes % 60}:${duration.inSeconds % 60}";
}

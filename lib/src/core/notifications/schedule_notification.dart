import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";

Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime time,
  required bool isPreReminder,
  String? payloadData,
}) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    log("Notification permissions not granted, skipping notification scheduling for id $id");
    return;
  }

  // Skip scheduling if the time is in the past
  if (time.isBefore(DateTime.now())) {
    log("Skipping notification id=$id — scheduled time ${time.toIso8601String()} is in the past");
    return;
  }

  if (isPreReminder) {
    try {
      await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar.fromDate(
          date: time,
          preciseAlarm: true,
          allowWhileIdle: true,
          repeats: false,
        ),
        content: NotificationContent(
          id: id,
          channelKey: "pre_reminders",
          title: title,
          body: title,
          locked: false,
          wakeUpScreen: true,
          actionType: ActionType.Default,
          customSound: "resource://raw/shaking_pill_bottle",
          category: NotificationCategory.Reminder,
          payload: {"payloadString": payloadData, "isPreReminder": "true"},
        ),
        actionButtons: payloadData == null
            ? null
            : [
                NotificationActionButton(
                  key: "acknowledge_pre_reminder",
                  label: "Acknowledge",
                  actionType: ActionType.DismissAction,
                ),
              ],
      );
      log("Pre-reminder notification scheduled: id=$id at ${time.toIso8601String()}");
    } catch (e) {
      log("Error creating pre-reminder notification: $e");
    }
  } else {
    try {
      await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar.fromDate(
          date: time,
          preciseAlarm: true,
          allowWhileIdle: true,
          repeats: false,
        ),
        content: NotificationContent(
          id: id,
          channelKey: "alarms_channel",
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
          locked: true,
          autoDismissible: false,
          criticalAlert: true,
          customSound: "resource://raw/shaking_pill_bottle",
          payload: {"payloadString": payloadData, "alarmId": id.toString()},
          backgroundColor: Colors.blueAccent,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "dismiss_alarm",
            label: "Dismiss Notification",
            actionType: ActionType.DismissAction,
            isDangerousOption: true,
          ),
          NotificationActionButton(
            key: "take_medicine_alarm",
            label: "Take Medicine",
            actionType: ActionType.Default,
          ),
        ],
      );
      log("Alarm notification scheduled: id=$id at ${time.toIso8601String()}");
    } catch (e) {
      log("Error creating alarm notification: $e");
    }
  }
}


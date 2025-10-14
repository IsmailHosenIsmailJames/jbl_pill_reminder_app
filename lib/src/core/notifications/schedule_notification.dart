import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";

import "../../screens/add_reminder/model/reminder_model.dart";

Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime time,
  required bool isPreReminder,
  ReminderModel? data,
}) async {
  if (isPreReminder == true) {
    await AwesomeNotificationsService.initPreReminderNotifications();
    AwesomeNotifications().createNotification(
      schedule: NotificationCalendar.fromDate(
        date: time,
        preciseAlarm: true,
        allowWhileIdle: true,
        repeats: false,
      ),
      content: NotificationContent(
        id: id,
        // Ensure this ID is unique for pre-reminders
        channelKey: "pre_reminders",
        // Define this channel in NotificationsService
        title: title,
        // Differentiate title
        body: title,
        locked: false,
        // Pre-reminders are usually not locked
        wakeUpScreen: true,
        actionType: ActionType.Default,
        // Opens the app or a specific screen
        customSound: "resource://raw/shaking_pill_bottle",
        // Optional: a softer sound
        category: NotificationCategory.Reminder,
        payload: {"payloadString": data?.toJson(), "isPreReminder": "true"},
      ),
      // Pre-reminders might not need action buttons or could have simpler ones
      actionButtons: data == null
          ? null
          : [
              NotificationActionButton(
                key: "acknowledge_pre_reminder",
                label: "Acknowledge",
                actionType: ActionType.DismissAction, // Simple dismiss
              ),
            ],
    );
  } else {
    await AwesomeNotificationsService.initAlarms();
    // Implementation for Alarm notification
    AwesomeNotifications().createNotification(
      schedule: NotificationCalendar.fromDate(
        date: time,
        preciseAlarm: true,
        allowWhileIdle: true,
        repeats: false,
      ),
      content: NotificationContent(
        id: id,
        // Ensure this ID is unique for alarms, potentially offset from reminder IDs
        channelKey: "alarms_channel",
        // IMPORTANT: Define this channel in NotificationsService
        title: title,
        body: body,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        // Wake up the screen
        fullScreenIntent: true,
        // Show as a full-screen intent (like an incoming call)
        locked: true,
        // Makes the notification persistent until interacted with
        autoDismissible: false,
        // User must interact
        criticalAlert: true,
        // Indicates a critical alert (iOS specific, good practice)
        customSound: "resource://raw/shaking_pill_bottle",
        // Or a more alarm-like sound
        payload: {"payloadString": data?.toJson(), "alarmId": id.toString()},
        backgroundColor: Colors.blueAccent, // Optional: for visual distinction
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
          actionType: ActionType.Default, // Opens the app
        ),
      ],
    );
    log("Alarm Notification Shown");
  }
}

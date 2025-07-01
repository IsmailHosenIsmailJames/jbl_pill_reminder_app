import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";

import "../../screens/add_reminder/model/reminder_model.dart";

Future<void> pushNotifications({
  required int id,
  required String title,
  required String body,
  required bool isPreReminder,
  required ReminderModel data,
  required bool isAlarm,
}) async {
  if (isPreReminder == true) {
    await AwesomeNotificationsService.initPreReminderNotifications();
    AwesomeNotifications().createNotification(
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
        actionType: ActionType.Default,
        // Opens the app or a specific screen
        customSound: "resource://raw/shaking_pill_bottle",
        // Optional: a softer sound
        category: NotificationCategory.Reminder,
        payload: {"payloadString": data.toJson(), "isPreReminder": "true"},
      ),
      // Pre-reminders might not need action buttons or could have simpler ones
      actionButtons: [
        NotificationActionButton(
          key: "acknowledge_pre_reminder",
          label: "Acknowledge",
          actionType: ActionType.DismissAction, // Simple dismiss
        ),
      ],
    );
    log("Pre-Reminder Notification Shown");
  } else if (isAlarm == false) {
    await AwesomeNotificationsService.initNotifications();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        // Must be unique for each notification
        channelKey: "reminders",
        // The channel key you created
        title: title,
        body: body,
        locked: isPreReminder ? false : true,
        actionType: ActionType.KeepOnTop,
        customSound: "resource://raw/shaking_pill_bottle",
        category: NotificationCategory.Reminder,
        payload: {"payloadString": data.toJson()},
      ),
      actionButtons: isPreReminder
          ? null
          : [
              NotificationActionButton(
                key: "dismiss",
                label: "Dismiss",
                actionType: ActionType.DismissAction,
              ),
              NotificationActionButton(
                key: "take_medicine",
                label: "Take Medicine",
                actionType: ActionType.Default,
              ),
            ],
    );
    log("Reminder Notification Shown");
  } else {
    await AwesomeNotificationsService.initAlarms();
    // Implementation for Alarm notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        // Ensure this ID is unique for alarms, potentially offset from reminder IDs
        channelKey: "alarms_channel",
        // IMPORTANT: Define this channel in NotificationsService
        title: title,
        body: body,
        category: NotificationCategory.Alarm,
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
        payload: {"payloadString": data.toJson(), "alarmId": id.toString()},
        backgroundColor: Colors.blueAccent, // Optional: for visual distinction
      ),
      actionButtons: [
        NotificationActionButton(
          key: "dismiss_alarm",
          label: "Dismiss Alarm",
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
        ),
        NotificationActionButton(
          key: "take_medicine_alarm",
          label: "Take Medicine",
          actionType: ActionType.Default, // Opens the app
        ),
      ],
      schedule:
          null, // For immediate alarms, schedule is null. For scheduled, you'd set it.
    );
    log("Alarm Notification Shown");
  }
}

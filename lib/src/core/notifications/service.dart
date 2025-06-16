import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";

class NotificationsService {
  static Future<void> initNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: "reminders",
          channelName: "Used for Reminders",
          channelDescription:
              "This channel is used for Reminders. When User add a Reminder, this channel will be used for remind the user",
          defaultColor: MyAppColors.primaryColor,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          playSound: true,
          enableVibration: true,
          soundSource: "resource://raw/shaking_pill_bottle",
          defaultRingtoneType: DefaultRingtoneType.Notification,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == "take_medicine") {}
    log("onActionReceivedMethod");
  }

  static Future<void> onNotificationCreatedMethod(receivedNotification) async {
    log("onNotificationCreatedMethod");
  }

  static Future<void> onNotificationDisplayedMethod(
      receivedNotification) async {
    log("onNotificationDisplayedMethod");
  }

  static Future<void> onDismissActionReceivedMethod(receivedAction) async {
    log("onDismissActionReceivedMethod");
  }
}

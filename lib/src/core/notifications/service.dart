import "dart:convert";
import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/app.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/take_medicine/take_medicine_page.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:shared_preferences/shared_preferences.dart";

class AwesomeNotificationsService {
  static bool isListening = false;
  static Future<void> initPreReminderNotifications() async {
    await registerListenNotifications();
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: "pre_reminders",
          channelName: "Pre-Reminders",
          channelDescription:
              "This channel is used for Pre-Reminders. This channel will be used to remind the user before the actual reminder time.",
          defaultColor: Colors.orangeAccent,
          // A different color for pre-reminders
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          playSound: true,
          enableVibration: true,
          groupAlertBehavior: GroupAlertBehavior.All,
          defaultPrivacy: NotificationPrivacy.Public,
          enableLights: true,
          ledOffMs: 500,
          ledOnMs: 500,
          soundSource: "resource://raw/shaking_pill_bottle",
          defaultRingtoneType: DefaultRingtoneType
              .Notification, // Keep as notification, not alarm
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> initNotifications() async {
    await registerListenNotifications();
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
          groupAlertBehavior: GroupAlertBehavior.All,
          defaultPrivacy: NotificationPrivacy.Public,
          enableLights: true,
          ledOffMs: 500,
          ledOnMs: 500,
          soundSource: "resource://raw/shaking_pill_bottle",
          defaultRingtoneType: DefaultRingtoneType.Notification,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> initAlarms() async {
    await registerListenNotifications();
    await AwesomeNotifications().initialize(
      null, // null for default icon
      [
        NotificationChannel(
          channelKey: "alarms_channel",
          channelName: "Pill Reminder Alarms",
          // Changed for clarity
          channelDescription:
              "Channel for critical pill reminder alarms that need immediate attention.",
          // Changed for clarity
          defaultColor: MyAppColors.primaryColor,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          // Max importance for alarms
          channelShowBadge: true,
          locked: true,
          // If true, notifications are not dismissible by swiping
          playSound: true,
          enableVibration: true,
          defaultPrivacy: NotificationPrivacy.Public,
          enableLights: true,
          groupAlertBehavior: GroupAlertBehavior.All,
          ledOffMs: 500,
          ledOnMs: 500,
          soundSource: "resource://raw/shaking_pill_bottle",
          // Your custom alarm sound
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          // IMPORTANT for alarms
          criticalAlerts: true, // IMPORTANT for iOS to bypass Do Not Disturb
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final actionNavigationDB = await SharedPreferences.getInstance();
    await actionNavigationDB.reload();
    log("onActionReceivedMethod");
    await actionNavigationDB.setString(
        "actionData", jsonEncode(receivedAction.toMap()));
    await actionNavigationDB.setInt(
        "actionDataTime", DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> registerListenNotifications() async {
    if (!isListening) {
      isListening = true;
      AwesomeNotifications().setListeners(
        onActionReceivedMethod:
            AwesomeNotificationsService.onActionReceivedMethod,
        onNotificationCreatedMethod:
            AwesomeNotificationsService.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            AwesomeNotificationsService.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            AwesomeNotificationsService.onDismissActionReceivedMethod,
      );
    }
  }
}

void customNavigation(Map? actionData) async {
  log(actionData.toString(), name: "customNavigation");
  if (actionData != null) {
    ReceivedAction receivedAction =
        ReceivedAction().fromMap(Map<String, dynamic>.from(actionData));
    String? reminderRawData = receivedAction.payload?["payloadString"];
    log(reminderRawData.toString(), name: "actionData");
    if (reminderRawData != null) {
      App.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => TakeMedicinePage(
            currentMedicationToTake: ReminderModel.fromJson(reminderRawData),
          ),
        ),
      );
    }
  }
}

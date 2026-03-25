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
  static bool _isInitialized = false;
  static bool _isListening = false;

  /// Initialize AwesomeNotifications ONCE with ALL channels.
  /// Must be called in main() and at the start of the background isolate.
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<void> initAllChannels() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await AwesomeNotifications().initialize(
      null,
      [
        // Channel for pre-reminders (15 min before)
        NotificationChannel(
          channelKey: "pre_reminders",
          channelName: "Pre-Reminders",
          channelDescription:
              "Reminds you before the actual pill-taking time so you can prepare.",
          defaultColor: Colors.orangeAccent,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: false,
          playSound: true,
          enableVibration: true,
          groupAlertBehavior: GroupAlertBehavior.All,
          defaultPrivacy: NotificationPrivacy.Public,
          enableLights: true,
          ledOffMs: 500,
          ledOnMs: 500,
          defaultRingtoneType: DefaultRingtoneType.Notification,
        ),
        // Channel for standard reminders
        NotificationChannel(
          channelKey: "reminders",
          channelName: "Pill Reminders",
          channelDescription:
              "Standard notifications for your scheduled pill reminders.",
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
          defaultRingtoneType: DefaultRingtoneType.Notification,
        ),
        // Channel for critical alarm-style notifications
        NotificationChannel(
          channelKey: "alarms_channel",
          channelName: "Pill Reminder Alarms",
          channelDescription:
              "Critical pill reminder alarms that need immediate attention.",
          defaultColor: MyAppColors.primaryColor,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true,
          playSound: true,
          enableVibration: true,
          defaultPrivacy: NotificationPrivacy.Public,
          enableLights: true,
          groupAlertBehavior: GroupAlertBehavior.All,
          ledOffMs: 500,
          ledOnMs: 500,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          criticalAlerts: true,
        ),
      ],
    );

    await registerListenNotifications();
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    log("Notification created: id=${receivedNotification.id}",
        name: "AwesomeNotificationsService");
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    log("Notification displayed: id=${receivedNotification.id}",
        name: "AwesomeNotificationsService");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log("Notification dismissed: id=${receivedAction.id}",
        name: "AwesomeNotificationsService");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final actionNavigationDB = await SharedPreferences.getInstance();
    await actionNavigationDB.reload();
    log("onActionReceivedMethod: id=${receivedAction.id}",
        name: "AwesomeNotificationsService");
    await actionNavigationDB.setString(
        "actionData", jsonEncode(receivedAction.toMap()));
    await actionNavigationDB.setInt(
        "actionDataTime", DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> registerListenNotifications() async {
    if (!_isListening) {
      _isListening = true;
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

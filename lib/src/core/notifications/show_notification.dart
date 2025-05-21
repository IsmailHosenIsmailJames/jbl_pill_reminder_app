import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";

Future<void> pushNotifications(
    {required int id,
    required String title,
    required String body,
    required bool isPreReminder,
    required bool isAlarm}) async {
  await NotificationsService.initNotifications();
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id, // Must be unique for each notification
      channelKey: "reminders", // The channel key you created
      title: title,
      body: body,
      locked: isPreReminder ? false : true,
      actionType: ActionType.KeepOnTop,
      customSound: "resource://raw/shaking_pill_bottle",
      category:
          isAlarm ? NotificationCategory.Alarm : NotificationCategory.Reminder,
    ),
    schedule: isAlarm
        ? NotificationCalendar.fromDate(
            date: DateTime.now().add(const Duration(seconds: 3)),
            repeats: true,
            preciseAlarm: true,
            allowWhileIdle: true,
          )
        : null,
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
  log("Notification Shown");
}

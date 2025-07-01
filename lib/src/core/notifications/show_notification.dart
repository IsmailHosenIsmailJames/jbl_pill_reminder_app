import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";

import "../../screens/add_reminder/model/reminder_model.dart";

Future<void> pushNotifications({
  required int id,
  required String title,
  required String body,
  required bool isPreReminder,
  required DateTime time,
  required ReminderModel data,
}) async {
  await NotificationsService.initNotifications();
  List<NotificationModel> notifications =
      await AwesomeNotifications().listScheduledNotifications();
  bool exitsEarly = false;
  for (NotificationModel notificationModel in notifications) {
    if (notificationModel.content?.id == id) {
      exitsEarly = true;
      break;
    }
  }

  if (exitsEarly) return;

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
    schedule: NotificationCalendar.fromDate(
      date: time,
      repeats: true,
      preciseAlarm: true,
      allowWhileIdle: true,
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
  log("Notification Shown");
}

import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:jbl_pills_reminder_app/src/core/notifications/service.dart';

Future<void> pushNotifications({
  required int id,
  required String title,
  required String body,
  required isPreReminder,
}) async {
  await NotificationsService.initNotifications();
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id, // Must be unique for each notification
      channelKey: 'reminders', // The channel key you created
      title: title,
      body: body,
      locked: isPreReminder ? false : true,
      actionType: ActionType.KeepOnTop,
    ),
    actionButtons: isPreReminder
        ? null
        : [
            NotificationActionButton(
              key: 'dismiss',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
            ),
            NotificationActionButton(
              key: 'take_medicine',
              label: 'Take Medicine',
              actionType: ActionType.Default,
            ),
          ],
  );
  log('Notification Shown');
}

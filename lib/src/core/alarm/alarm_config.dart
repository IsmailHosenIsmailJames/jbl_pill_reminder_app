import "dart:io";
import "dart:ui";

import "package:alarm/model/alarm_settings.dart";
import "package:alarm/model/notification_settings.dart";
import "package:alarm/model/volume_settings.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";

AlarmSettings getAlarmConfig({
  required int id,
  required DateTime timeOfAlarm,
  required String title,
  required String body,
  required ReminderModel data,
}) {
  return AlarmSettings(
    id: id,
    dateTime: timeOfAlarm,
    assetAudioPath: "assets/sound/shaking_pill_bottle.mp3",
    loopAudio: true,
    vibrate: true,
    warningNotificationOnKill: Platform.isIOS,
    androidFullScreenIntent: true,
    volumeSettings: VolumeSettings.fade(
      volume: 0.8,
      fadeDuration: const Duration(seconds: 5),
      volumeEnforced: false,
    ),
    payload: data.toJson(),
    notificationSettings: NotificationSettings(
      title: title,
      body: body,
      stopButton: "Stop the alarm",
      icon: "notification_icon",
      iconColor: const Color(0xff862778),
    ),
  );
}

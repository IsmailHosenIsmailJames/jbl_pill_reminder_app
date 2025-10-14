import "package:alarm/alarm.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";

Future<void> scheduleAlarm({
  required int id,
  required String title,
  required String description,
  required DateTime time,
  required ReminderModel? data,
}) async {
  Alarm.set(
    alarmSettings: AlarmSettings(
      id: id,
      dateTime: time,
      assetAudioPath: "assets/sound/shaking_pill_bottle.mp3",
      volumeSettings:
          const VolumeSettings.fixed(volume: 1, volumeEnforced: true),
      notificationSettings: NotificationSettings(
        title: title,
        body: description,
        stopButton: "Stop Alarm",
      ),
    ),
  );
}

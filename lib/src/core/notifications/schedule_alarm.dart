import "package:alarm/alarm.dart";

Future<void> scheduleAlarm({
  required int id,
  required String title,
  required String description,
  required DateTime time,
}) async {
  Alarm.set(
    alarmSettings: AlarmSettings(
      id: id,
      dateTime: time,
      androidFullScreenIntent: true,
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


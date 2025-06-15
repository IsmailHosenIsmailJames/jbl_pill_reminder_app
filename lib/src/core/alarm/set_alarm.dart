import "package:alarm/alarm.dart";

Future<bool> setAlarm(AlarmSettings alarmSettings) async {
  final previousAlarm = await Alarm.getAlarm(alarmSettings.id);
  if (previousAlarm != null) {
    if (previousAlarm.dateTime.hour == alarmSettings.dateTime.hour &&
        previousAlarm.dateTime.minute == alarmSettings.dateTime.minute &&
        previousAlarm.dateTime.day == alarmSettings.dateTime.day &&
        previousAlarm.dateTime.month == alarmSettings.dateTime.month) {
      return true;
    } else {
      await Alarm.stop(alarmSettings.id);
    }
  }
  return await Alarm.set(alarmSettings: alarmSettings);
}

import "dart:developer";

import "package:alarm/alarm.dart";

Future<bool> setAlarm(AlarmSettings alarmSettings) async {
  log("Alarm stop", name: "alarm");
  await Alarm.init();
  final previousAlarm = await Alarm.getAlarm(alarmSettings.id);
  if (previousAlarm != null) {
    if (previousAlarm.dateTime.hour == alarmSettings.dateTime.hour &&
        previousAlarm.dateTime.minute == alarmSettings.dateTime.minute &&
        previousAlarm.dateTime.day == alarmSettings.dateTime.day &&
        previousAlarm.dateTime.month == alarmSettings.dateTime.month) {
      log("Alarm already Scheduled", name: "alarm");
      return true;
    } else {
      log("Alarm stop", name: "alarm");
      await Alarm.stop(alarmSettings.id);
    }
  }
  log("Alarm stop", name: "alarm");
  return await Alarm.set(alarmSettings: alarmSettings);
}

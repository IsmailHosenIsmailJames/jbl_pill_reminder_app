import "dart:io";

import "package:alarm/alarm.dart";
import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:jbl_pills_reminder_app/app.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/callback_dispacher.dart";
import "package:permission_handler/permission_handler.dart";
import "package:workmanager/workmanager.dart";

bool isUpdateChecked = false;

List<String> foregroundNotification = [];

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await analyzeDatabaseAndScheduleReminder(
        reloadDB: inputData?["inputData"] == true);
    return Future.value(true);
  });
}

Future<bool> requestPermissions() async {
  var notificationPermission = await Permission.notification.status;
  if (notificationPermission != PermissionStatus.granted) {
    notificationPermission = await Permission.notification.request();
  }

  var ignoreBatteryOpt = await Permission.ignoreBatteryOptimizations.status;
  if (ignoreBatteryOpt != PermissionStatus.granted) {
    ignoreBatteryOpt = await Permission.ignoreBatteryOptimizations.request();
  }

  if (Platform.isAndroid) {
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    if (!await Permission.scheduleExactAlarm.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }
  return notificationPermission == PermissionStatus.granted;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Alarm.init();
  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    "background_task",
    "process_db",
    inputData: {"reloadDB": true},
    frequency: const Duration(minutes: 15),
  );

  DateTime now = DateTime.now();
  Duration diff = now
      .add(Duration(days: now.day + 1))
      .copyWith(hour: 0, minute: 0)
      .difference(now);

  await Workmanager().registerPeriodicTask(
    "day_task",
    "process_db",
    inputData: {"reloadDB": true},
    initialDelay: diff,
    frequency: const Duration(days: 1),
  );

  await Hive.initFlutter();
  await Hive.openBox("user_db");
  await Hive.openBox("reminder_db");
  await Hive.openBox("reminder_done");

  runApp(const App());
}

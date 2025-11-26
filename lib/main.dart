import "dart:io";

import "package:alarm/alarm.dart";
import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:jbl_pills_reminder_app/app.dart";
import "package:jbl_pills_reminder_app/src/core/background/callback_dispacher.dart";
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

Future<bool> requestPermissions(BuildContext context) async {
  var notificationStatus = await Permission.notification.status;
  var ignoreBatteryStatus = await Permission.ignoreBatteryOptimizations.status;
  var scheduleExactAlarmStatus = PermissionStatus.granted;

  if (Platform.isAndroid) {
    scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
  }

  if (notificationStatus == PermissionStatus.granted &&
      ignoreBatteryStatus == PermissionStatus.granted &&
      scheduleExactAlarmStatus == PermissionStatus.granted) {
    return true;
  }

  bool isUserProceedToPermission = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "This app requires notification and background permissions to send you timely pill reminders, even when the app is closed. Please grant these permissions to ensure you don't miss any doses.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Grant Permissions"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ) ??
      false;

  if (!isUserProceedToPermission) return false;

  if (notificationStatus != PermissionStatus.granted) {
    notificationStatus = await Permission.notification.request();
  }

  if (ignoreBatteryStatus != PermissionStatus.granted) {
    ignoreBatteryStatus = await Permission.ignoreBatteryOptimizations.request();
  }

  if (Platform.isAndroid) {
    if (scheduleExactAlarmStatus != PermissionStatus.granted) {
      scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.request();
    }
  }

  return notificationStatus == PermissionStatus.granted;
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

import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';

import 'jbl_pill_reminder_app.dart';
import 'src/core/foreground_service/foreground_task_manager.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  if (await ForegroundTaskManager.checkPermissions()) {
    log("Form main");
    ForegroundTaskManager.initService();
    await ForegroundTaskManager.startService();
  }
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SharedPrefs.init();
  await LocalNotifications.initializeService();

  await Alarm.init();
  runApp(const JblPillReminderApp());
}

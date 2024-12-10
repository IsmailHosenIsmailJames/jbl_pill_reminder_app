import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';

import 'jbl_pill_reminder_app.dart';
import 'src/core/foreground_service/foreground_task_manager.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterForegroundTask.initCommunicationPort();
  if (await checkPermissions()) {
    log("Form main");
    initService();
    await startService();
  }

  await SharedPrefs.init();
  await LocalNotifications.initializeService();
  cameras = await availableCameras();
  await Alarm.init();
  runApp(const JblPillReminderApp());
}

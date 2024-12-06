import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jbl_pill_reminder_app/src/core/background_service/background_service.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';

import 'jbl_pill_reminder_app.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SharedPrefs.init();
  await LocalNotifications.initializeService();
  MyBackgroundService.init();
  await Alarm.init();
  runApp(const JblPillReminderApp());
}

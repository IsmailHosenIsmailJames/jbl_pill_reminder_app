import "package:flutter/material.dart";
import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:jbl_pills_reminder_app/app.dart";

bool isUpdateChecked = false;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterForegroundTask.initCommunicationPort();

  await Hive.initFlutter();
  await Hive.openBox("user_db");
  await Hive.openBox("reminder_db");
  await Hive.openBox("reminder_done");

  runApp(const App());
}

import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/core/database/sqlite_helper.dart";
import "package:jbl_pills_reminder_app/app.dart";
import "package:permission_handler/permission_handler.dart";
import "package:jbl_pills_reminder_app/src/core/functions/dependency_injection.dart";
import "package:firebase_core/firebase_core.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/fcm_service.dart";

Future<bool> requestPermissions(BuildContext context) async {
  var notificationStatus = await Permission.notification.status;
  var ignoreBatteryStatus = await Permission.ignoreBatteryOptimizations.status;

  if (notificationStatus == PermissionStatus.granted &&
      ignoreBatteryStatus == PermissionStatus.granted) {
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
                "This app requires notification permissions to send you timely pill reminders. Please grant these permissions to ensure you don't miss any doses.",
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
              const SizedBox(height: 60),
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

  return notificationStatus == PermissionStatus.granted;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM
  await FCMService.initialize();

  await SqliteHelper.initDB();
  await initDependencies();

  final localDb = LocalDbRepository();
  String? userInfo = await localDb.getPreference("user_info");
  bool isLoggedIn = userInfo != null;

  if (isLoggedIn) {
    // Register FCM token if already logged in
    FCMService.getTokenAndRegister();
  }

  runApp(App(isLoggedIn: isLoggedIn));
}

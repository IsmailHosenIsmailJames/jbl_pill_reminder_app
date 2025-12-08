import "dart:io";

import "package:alarm/alarm.dart";
import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:jbl_pills_reminder_app/app.dart";
import "package:jbl_pills_reminder_app/src/core/background/background_task_manager.dart";
import "package:jbl_pills_reminder_app/src/core/background/callback_dispacher.dart";
import "package:open_settings_plus/open_settings_plus.dart";
import "package:permission_handler/permission_handler.dart";
import "package:workmanager/workmanager.dart";

bool isUpdateChecked = false;

List<String> foregroundNotification = [];

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Hive for background isolate
      await Hive.initFlutter();

      // Initialize Alarm
      await Alarm.init();

      // Initialize AwesomeNotifications for background isolate
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'pill_reminder_channel',
            channelName: 'Pill Reminders',
            channelDescription: 'Notification channel for pill reminders',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),
        ],
      );

      // Execute the actual task
      await analyzeDatabaseAndScheduleReminder(
          reloadDB: inputData?["reloadDB"] == true);

      return Future.value(true);
    } catch (e) {
      print("Error in background task: $e");
      return Future.value(false);
    }
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
    // Show additional battery optimization tip
    if (Hive.box("user_db")
        .get("show_battery_optimization_tip", defaultValue: true)) {
      _showBatteryOptimizationTip(context);
    }
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
              const Icon(
                Icons.medication,
                size: 48,
                color: Color(0xFF9D50DD),
              ),
              const SizedBox(height: 16),
              const Text(
                "Required Permissions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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

  // Show additional setup tip for autostart
  if (notificationStatus == PermissionStatus.granted) {
    if (Hive.box("user_db")
        .get("show_battery_optimization_tip", defaultValue: true)) {
      _showBatteryOptimizationTip(context);
    }
  }

  return notificationStatus == PermissionStatus.granted;
}

// Helper function to show battery optimization tips
Future<void> _showBatteryOptimizationTip(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: const Row(
        children: [
          Icon(Icons.battery_alert, color: Color(0xFF9D50DD)),
          SizedBox(width: 8),
          Text("Important Setup"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "To ensure you never miss a pill reminder, please:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTipItem("1", "Disable battery optimization for this app"),
            _buildTipItem(
                "2", "Enable Autostart (if available on your device)"),
            _buildTipItem(
                "3", "Remove app from battery saver/power saving modes"),
            const SizedBox(height: 12),
            Text(
              "Common manufacturer settings:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildManufacturerTip("Xiaomi/Redmi",
                "Settings → Apps → Manage apps → Pill Reminder → Autostart & Battery saver → Enable"),
            _buildManufacturerTip("Samsung",
                "Settings → Apps → Pill Reminder → Battery → Unrestricted"),
            _buildManufacturerTip("Huawei",
                "Settings → Apps → Apps → Pill Reminder → Battery → App launch → Manage manually"),
            _buildManufacturerTip("Oppo/Realme",
                "Settings → Battery → Battery optimization → Pill Reminder → Don't optimize"),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: OutlinedButton(
            onPressed: () {
              Hive.box("user_db").put("show_battery_optimization_tip", false);
              Navigator.pop(context);
            },
            child: const Text("Don't show again"),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Open app-specific settings where user can disable battery optimization
              final openSettings = OpenSettingsPlus.shared;
              if (openSettings is OpenSettingsPlusAndroid) {
                await openSettings.applicationDetails();
              } else if (openSettings is OpenSettingsPlusIOS) {
                await openSettings.appSettings();
              }
            },
            child: const Text("Open Settings"),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTipItem(String number, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF9D50DD),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    ),
  );
}

Widget _buildManufacturerTip(String manufacturer, String instruction) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• $manufacturer:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            instruction,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    ),
  );
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Alarm.init();

  // Initialize AwesomeNotifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'pill_reminder_channel',
        channelName: 'Pill Reminders',
        channelDescription: 'Notification channel for pill reminders',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ],
  );

  // Initialize WorkManager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Set to false for production
  );

  // Register all background tasks using the helper
  await BackgroundTaskManager.registerAllTasks();

  await Hive.initFlutter();
  await Hive.openBox("user_db");
  await Hive.openBox("reminder_db");
  await Hive.openBox("reminder_done");

  runApp(const App());
}

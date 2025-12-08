import 'dart:io';
import 'package:workmanager/workmanager.dart';

/// Helper class to manage WorkManager background tasks
class BackgroundTaskManager {
  static const String _backgroundTaskName = "background_task";
  static const String _dayTaskName = "day_task";
  static const String _taskType = "process_db";

  /// Register all background tasks
  static Future<void> registerAllTasks() async {
    try {
      // Cancel existing tasks first to avoid duplicates
      await Workmanager().cancelAll();

      // Register periodic task (every 15 minutes)
      await _registerBackgroundTask();

      // Register daily task
      await _registerDailyTask();
    } catch (e) {
      print("Error registering background tasks: $e");
    }
  }

  /// Register the 15-minute periodic background task
  static Future<void> _registerBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _taskType,
      inputData: {"reloadDB": true},
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(seconds: 30),
    );
  }

  /// Register the daily task
  static Future<void> _registerDailyTask() async {
    DateTime now = DateTime.now();
    Duration diff = now
        .add(Duration(days: 1))
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)
        .difference(now);

    await Workmanager().registerPeriodicTask(
      _dayTaskName,
      _taskType,
      inputData: {"reloadDB": true},
      initialDelay: diff,
      frequency: const Duration(days: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(seconds: 30),
    );
  }

  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  /// Check if device has aggressive battery optimization (Xiaomi, Huawei, etc.)
  static Future<bool> hasAggressiveBatteryOptimization() async {
    if (!Platform.isAndroid) return false;

    // List of manufacturers known for aggressive battery optimization:
    // xiaomi, huawei, honor, oppo, vivo, realme, oneplus, samsung, asus, nokia, lenovo, meizu
    // You would need to use a plugin like device_info_plus to get the manufacturer
    // For now, we assume it might be aggressive
    return true;
  }
}

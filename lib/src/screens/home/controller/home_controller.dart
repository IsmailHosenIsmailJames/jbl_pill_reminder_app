import "dart:convert";
import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:jbl_pills_reminder_app/src/core/background/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/core/functions/has_internet_connection.dart";
import "package:http/http.dart" as http;
import "package:get/get.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:toastification/toastification.dart";

class HomeController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;
  RxBool isLoading = false.obs;

  Rx<ReminderModel?> nextReminder = Rx<ReminderModel?>(null);
  RxList<ReminderModel> listOfTodaysReminder = RxList<ReminderModel>([]);
  RxList<ReminderModel> listOfAllReminder = RxList<ReminderModel>([]);

  final _localDb = LocalDbRepository();

  /// Loads all locally saved reminders into [listOfAllReminder].
  Future<void> reloadLocalReminders() async {
    final map = await _localDb.getAllReminders();
    final reminders =
        map.values.map((e) => ReminderModel.fromJson(e)).toList()
          ..sort((a, b) => a.schedule!.startDate.compareTo(b.schedule!.startDate));
    listOfAllReminder.value = reminders;
  }

  /// Fetches reminders from the server, saves them locally, then reloads the
  /// list and reschedules notifications. No-ops when offline.
  Future<void> syncRemindersFromServer(String phoneNumber) async {
    if (!await hasInternetConnection()) return;

    isLoading.value = true;
    try {
      final serverData = await _fetchAllFromServer(phoneNumber);
      for (final reminder in serverData) {
        final model = ReminderModel.fromMap(reminder);
        await _localDb.saveReminder(model.id, model.toJson());
      }
      await reloadLocalReminders();
      if (await AwesomeNotifications().isNotificationAllowed()) {
        await analyzeDatabaseAndScheduleReminder();
      }
    } catch (e) {
      log("syncRemindersFromServer error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllFromServer(
      String phoneNumber) async {
    final url = Uri.parse("${baseAPI}reminders/$phoneNumber");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.cast<Map<String, dynamic>>();
    }
    log("_fetchAllFromServer failed: ${response.statusCode}");
    return [];
  }

  static Future<List<Map<String, dynamic>>> getAllRemindersFromServer(
      BuildContext context, String phoneNumber) async {
    final url = Uri.parse("${baseAPI}reminders/$phoneNumber");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        toastification.show(
          context: context,
          title: const Text("Failed to get reminders"),
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
        );
        return [];
      }
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getSingleReminderFromServer(
      BuildContext context, String phoneNumber, String id) async {
    final url = Uri.parse("${baseAPI}reminders/$phoneNumber/$id");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      toastification.show(
        context: context,
        title: const Text("Failed to get reminders"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
      return null;
    }
  }

  static Future<bool> updateReminder(BuildContext context, String phoneNumber,
      String id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse("${baseAPI}reminders/$phoneNumber/$id/update/");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      toastification.show(
        context: context,
        title: const Text("Reminder updated successfully"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.success,
      );
      return true; // Updated successfully
    } else {
      toastification.show(
        context: context,
        title: const Text("Failed to update reminder"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
      return false;
    }
  }

  static Future<bool> deleteReminder(
      BuildContext context, String phoneNumber, String id) async {
    final url = Uri.parse("${baseAPI}reminders/$phoneNumber/$id/delete/");

    final response = await http.delete(url);

    if (response.statusCode == 204) {
      toastification.show(
        context: context,
        title: const Text("Reminder deleted successfully"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.success,
      );
      return true;
    } else {
      toastification.show(
        context: context,
        title: const Text("Failed to delete reminder"),
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
      );
      return false;
    }
  }

  static Future<void> backupReminderHistory(String phone) async {
    log("backupReminderHistory");
    final localDb = LocalDbRepository();
    final allDone = await localDb.getAllRemindersDone();

    allDone.forEach(
      (key, value) async {
        Map reminderData = jsonDecode(value);
        final isDoneBackup = reminderData["doneBackup"];
        if (isDoneBackup == null || isDoneBackup == false) {
          if (await backupSingleHistory(
              Map<String, dynamic>.from(reminderData), phone)) {
            reminderData["doneBackup"] = true;
            await localDb.saveReminderDone(key, jsonEncode(reminderData));
          }
        }
      },
    );
  }

  static Future<bool> backupSingleHistory(
      Map<String, dynamic> historyData, String phone) async {
    log("backupSingleHistory");
    final url = Uri.parse("${baseAPI}history/backup/");
    historyData.remove("doneBackup");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone_number": phone, "data": historyData}),
    );

    if (response.statusCode == 201) {
      return true; // Successfully backed up
    } else {
      print("Failed to backup history: ${response.body}");
      return false;
    }
  }
}

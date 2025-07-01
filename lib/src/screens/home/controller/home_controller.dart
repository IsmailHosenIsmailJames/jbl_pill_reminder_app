import "dart:convert";
import "dart:developer";

import "package:flutter/material.dart";
import "package:hive/hive.dart";
import "package:http/http.dart" as http;
import "package:get/get.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:toastification/toastification.dart";

class HomeController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;

  Rx<ReminderModel?> nextReminder = Rx<ReminderModel?>(null);
  RxList<ReminderModel> listOfTodaysReminder = RxList<ReminderModel>([]);
  RxList<ReminderModel> listOfAllReminder = RxList<ReminderModel>([]);

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
    final reminderDoneDB = await Hive.openBox("reminder_done");

    reminderDoneDB.toMap().forEach(
      (key, value) async {
        Map reminderData = jsonDecode(value);
        final isDoneBackup = reminderData["doneBackup"];
        if (isDoneBackup == null || isDoneBackup == false) {
          if (await backupSingleHistory(
              Map<String, dynamic>.from(reminderData), phone)) {
            reminderData["doneBackup"] = true;
            await reminderDoneDB.put(key, jsonEncode(reminderData));
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

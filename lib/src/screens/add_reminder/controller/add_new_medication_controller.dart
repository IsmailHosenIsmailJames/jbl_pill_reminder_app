import 'dart:math';
import 'dart:developer' as dev;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:jbl_pills_reminder_app/src/api/apis.dart';

import '../model/reminder_model.dart';

class AddNewReminderModelController extends GetxController {
  Rx<ReminderModel> reminders =
      ReminderModel(id: (Random().nextInt(100000000) + 100000000).toString())
          .obs;

// Function to Create a Reminder
  Future<http.Response?> createReminder(
      Map<String, dynamic> reminderData) async {
    try {
      final url = Uri.parse('${baseAPI}reminders/create/');
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = jsonEncode(reminderData); // Convert reminderData to JSON
      dev.log(body);

      try {
        final response = await http.post(url, headers: headers, body: body);
        dev.log(response.body);
        dev.log(response.statusCode.toString());
        return response;
      } catch (e) {
        print('Error creating reminder: $e');
        rethrow; // Re-throw the error so the caller can handle it
      }
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }
}

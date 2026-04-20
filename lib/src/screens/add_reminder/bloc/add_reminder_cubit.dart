import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jbl_pills_reminder_app/src/api/apis.dart';
import 'package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart';


class AddReminderCubit extends Cubit<ReminderModel> {
  AddReminderCubit()
      : super(ReminderModel(
            id: (Random().nextInt(100000000) + 100000000).toString()));

  void updateReminder(ReminderModel newReminder) {
    emit(newReminder);
  }

  void resetReminder() {
    emit(ReminderModel(
        id: (Random().nextInt(100000000) + 100000000).toString()));
  }

  Future<http.Response?> createReminder(
      Map<String, dynamic> reminderData) async {
    try {
      final url = Uri.parse("${baseAPI}reminders/create/");
      final headers = {
        "Content-Type": "application/json",
      };

      final body = jsonEncode(reminderData);
      dev.log(body);

      try {
        final response = await http.post(url, headers: headers, body: body);
        dev.log(response.body);
        dev.log(response.statusCode.toString());
        return response;
      } catch (e) {
        print("Error creating reminder: $e");
        rethrow;
      }
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }
}

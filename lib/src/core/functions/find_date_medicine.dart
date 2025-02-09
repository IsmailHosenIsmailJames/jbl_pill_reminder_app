import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart';

import '../../resources/frequency.dart';
import '../../screens/add_reminder/model/schedule_model.dart';

List<ReminderModel> findDateMedicine(
    List<ReminderModel> listOfMedications, DateTime date) {
  List<ReminderModel> todaysMedication = [];
  for (ReminderModel medicationModel in listOfMedications) {
    String frequencyType = medicationModel.schedule?.frequency?.type ?? '';
    List<TimeModel>? listOfTime = medicationModel.schedule?.times;
    if (listOfTime != null) {
      if (medicationModel.schedule?.startDate != null &&
          medicationModel.schedule?.endDate != null) {
        // is between start and end Date
        if (!(medicationModel.schedule!.startDate.millisecondsSinceEpoch <=
                date.millisecondsSinceEpoch &&
            medicationModel.schedule!.endDate!.millisecondsSinceEpoch >=
                date.millisecondsSinceEpoch)) {
          continue;
        }
      }
      // everyday
      if (frequencyType == frequencyTypeList[0]) {
        log('Frequency type: Every day');
        todaysMedication.add(medicationModel);
      }
      // every X days
      else if (frequencyType == frequencyTypeList[1]) {
        DateTime? startDate = medicationModel.schedule?.startDate;
        int? distance = medicationModel.schedule?.frequency?.everyXDays;

        if (startDate != null && distance != null) {
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          date = DateTime(date.year, date.month, date.day);
          int difference = date.difference(startDate).inDays;
          if (difference % distance == 0) {
            todaysMedication.add(medicationModel);
          }
        }
      }
      // weekly
      else if (frequencyType == frequencyTypeList[2]) {
        DateFormat formatter = DateFormat('EEEE');
        String weekday = formatter.format(date);
        List<String>? listOfDay =
            medicationModel.schedule?.frequency?.weekly?.days;
        if (listOfDay != null) {
          if (listOfDay.contains(weekday)) {
            todaysMedication.add(medicationModel);
          }
        }
      }
      // monthly
      else if (frequencyType == frequencyTypeList[3]) {
        DateFormat formatter = DateFormat('d');
        String day = formatter.format(date);
        List<int>? listOfDay =
            medicationModel.schedule?.frequency?.monthly?.dates;
        if (listOfDay != null) {
          if (listOfDay.contains(int.parse(day))) {
            todaysMedication.add(medicationModel);
          }
        }
      }
      // Specific dates on a year
      else if (frequencyType == frequencyTypeList[4]) {
        List<DateTime> listOfDateInYears =
            medicationModel.schedule?.frequency?.yearly?.dates ?? [];
        for (var element in listOfDateInYears) {
          if (element.year == date.year &&
              element.month == date.month &&
              element.day == date.day) {
            todaysMedication.add(medicationModel);
          }
        }
      }
    }
  }
  return todaysMedication;
}

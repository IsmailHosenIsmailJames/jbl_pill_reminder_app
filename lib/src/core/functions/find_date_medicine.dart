import 'package:intl/intl.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/schedule_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';

List<MedicationModel> findDateMedicine(
    List<MedicationModel> listOfMedications, DateTime date) {
  List<MedicationModel> todaysMedication = [];
  for (MedicationModel medicationModel in listOfMedications) {
    String frequencyType = medicationModel.schedule?.frequency?.type ?? "";
    List<TimeModel>? listOfTime = medicationModel.schedule?.times;

    if (listOfTime != null) {
      if (medicationModel.schedule?.startDate != null &&
          medicationModel.schedule?.endDate != null) {
        // is between start and end Date
        if (!(date.isAfter(medicationModel.schedule!.startDate!) &&
            date.isBefore(medicationModel.schedule!.endDate!))) {
          continue;
        }
      }
      // everyday
      if (frequencyType == frequencyTypeList[0]) {
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
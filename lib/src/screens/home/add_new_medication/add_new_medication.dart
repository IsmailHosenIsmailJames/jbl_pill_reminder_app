import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/resources/keys.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_1/add_basic_info_of_medication.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/controller/home_controller.dart';
import 'package:toastification/toastification.dart';

class AddNewMedication extends StatefulWidget {
  const AddNewMedication({super.key});

  @override
  State<AddNewMedication> createState() => _AddNewMedicationState();
}

class _AddNewMedicationState extends State<AddNewMedication> {
  final medicationController = Get.put(AddNewMedicationController());
  PageController pageController =
      PageController(keepPage: true, initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Medication"),
      ),
      body: Column(
        children: [
          const Expanded(
            child: AddBasicInfoOfMedication(),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final medication = medicationController.medications.value;

                String? error = checkValidityOfMedication(
                  medication,
                );

                if (error == null) {
                  final sharedPrefs = SharedPrefs.prefs;
                  await sharedPrefs.reload();
                  List<String>? allMedication =
                      sharedPrefs.getStringList(allPrescriptionKey);
                  allMedication ??= [];
                  allMedication.add(medication.toJson());
                  log("Going to save : $allMedication");
                  await sharedPrefs.setStringList(
                      allPrescriptionKey, allMedication);
                  final HomeController homeController = Get.find();
                  List<MedicationModel> allMedicationModel = [];
                  for (var element in allMedication) {
                    allMedicationModel.add(MedicationModel.fromJson(element));
                  }
                  homeController.listOfAllMedications.value =
                      allMedicationModel;
                  toastification.show(
                    title: const Text("Successfully Saved"),
                    type: ToastificationType.success,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                  Get.back();
                } else {
                  toastification.show(
                    title: Text(error),
                    type: ToastificationType.error,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.done,
                    size: 16,
                  ),
                  Gap(10),
                  Text("Save"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String? checkValidityOfMedication(MedicationModel medication) {
    if (medication.title != null || medication.title?.isNotEmpty == true) {
      log("Pass form validation");
    } else {
      return "Please fill medication title";
    }

    // check medicine requirement
    if (medication.medicines?.isNotEmpty == true) {
      log("Found ${medication.medicines?.length} medicine");
    } else {
      return "Please add medicine";
    }

    // check start and end date
    if (medication.schedule?.endDate != null) {
      log("Start Date ${medication.schedule?.startDate} and Start Date ${medication.schedule?.endDate}");
    } else {
      log(medication.toJson());
      log((medication.schedule?.startDate ?? "").toString());
      return "Pick start and end date";
    }

    // check frequency of medicine
    final frequency = medication.schedule?.frequency;
    if (frequency != null &&
        frequency.type != null &&
        (frequency.type == frequencyTypeList[0] ||
            (frequency.type == frequencyTypeList[1] &&
                frequency.everyXDays != null) ||
            (frequency.type == frequencyTypeList[2] &&
                frequency.weekly != null) ||
            (frequency.type == frequencyTypeList[3] &&
                frequency.monthly != null) ||
            (frequency.type == frequencyTypeList[4] &&
                frequency.yearly != null))) {
      log("Pass frequency:${frequency.toJson()}");
    } else {
      return "Please add frequency of medicine";
    }

    // check alarms

    if (medication.schedule?.times?.isNotEmpty == true) {
      log("Added ${medication.schedule?.times?.length}");
    } else {
      return "Please add Alarm Time";
    }

    return null;
  }
}

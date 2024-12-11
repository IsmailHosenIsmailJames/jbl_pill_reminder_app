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
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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

  int currentPagePosition = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Medication"),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  currentPagePosition = value;
                });
              },
              children: [
                const AddBasicInfoOfMedication(),
                const SetMedicationSchedule(),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Center(
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: 2,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    activeDotColor: MyAppColors.primaryColor,
                    dotWidth: MediaQuery.of(context).size.width * 0.1,
                    expansionFactor: 8,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16,
                        ),
                        Gap(5),
                        Text("Back"),
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final medication = medicationController.medications.value;
                      if (currentPagePosition == 0) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      } else {
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
                            allMedicationModel
                                .add(MedicationModel.fromJson(element));
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
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(currentPagePosition == 1 ? "Save" : "Next Step"),
                        const Gap(5),
                        Icon(
                          currentPagePosition == 1
                              ? Icons.done
                              : Icons.arrow_forward,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String? checkValidityOfMedication(MedicationModel medication) {
    // check form validity
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
    if (medication.schedule?.startDate != null &&
        medication.schedule?.endDate != null) {
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

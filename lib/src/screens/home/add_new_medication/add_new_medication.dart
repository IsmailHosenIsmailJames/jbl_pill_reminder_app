import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_1/add_basic_info_of_medication.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AddNewMedication extends StatefulWidget {
  const AddNewMedication({super.key});

  @override
  State<AddNewMedication> createState() => _AddNewMedicationState();
}

class _AddNewMedicationState extends State<AddNewMedication> {
  final medicationController = Get.put(AddNewMedicationController());
  PageController pageController = PageController();
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
                    onPressed: () {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Next Step"),
                        Gap(5),
                        Icon(
                          Icons.arrow_forward,
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
}

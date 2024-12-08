import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/add_basic_info_of_medication.dart';
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
        title: Text("Add New Medication"),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                AddBasicInfoOfMedication(),
                AddBasicInfoOfMedication(),
                AddBasicInfoOfMedication()
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Center(
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    activeDotColor: MyAppColors.primaryColor,
                    dotWidth: MediaQuery.of(context).size.width * 0.1,
                    expansionFactor: 7,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {},
                child: Text("Next"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

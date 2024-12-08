import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';

class AddBasicInfoOfMedication extends StatefulWidget {
  const AddBasicInfoOfMedication({super.key});

  @override
  State<AddBasicInfoOfMedication> createState() =>
      _AddBasicInfoOfMedicationState();
}

class _AddBasicInfoOfMedicationState extends State<AddBasicInfoOfMedication> {
  final medicationController = Get.put(AddNewMedicationController());

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [],
    );
  }
}

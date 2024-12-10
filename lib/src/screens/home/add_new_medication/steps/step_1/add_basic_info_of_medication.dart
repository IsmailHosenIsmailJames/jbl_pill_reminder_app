import 'dart:developer';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_1/add_medicine.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:jbl_pill_reminder_app/src/widgets/textfieldinput_decoration.dart';

class AddBasicInfoOfMedication extends StatefulWidget {
  const AddBasicInfoOfMedication({super.key});

  @override
  State<AddBasicInfoOfMedication> createState() =>
      _AddBasicInfoOfMedicationState();
}

class _AddBasicInfoOfMedicationState extends State<AddBasicInfoOfMedication> {
  final medicationController = Get.put(AddNewMedicationController());

  late TextEditingController medicationTitleController =
      TextEditingController(text: medicationController.medications.value.title);
  late TextEditingController medicationReasonController = TextEditingController(
      text: medicationController.medications.value.reason);
  late TextEditingController medicationNotesController = TextEditingController(
      text: medicationController.medications.value.prescription?.notes);

  @override
  Widget build(BuildContext context) {
    log(medicationController.medications.value.toJson().toString());
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        Row(
          children: [
            Text(
              "Medication Title",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " *",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Gap(5),
        customTextFieldDecoration(
          textFormField: TextFormField(
            controller: medicationTitleController,
            validator: (medicationTitle) {
              if (medicationTitle == null || medicationTitle.isEmpty) {
                return "Medication title can't ne empty";
              }
              return null;
            },
            onChanged: (medicationTitle) {
              medicationController.medications.value.title = medicationTitle;
            },
            decoration: InputDecoration(hintText: "type title here..."),
          ),
        ),
        Gap(15),
        Text(
          "Medication Reason",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(5),
        customTextFieldDecoration(
          textFormField: TextFormField(
            controller: medicationReasonController,
            validator: (medicationReason) {
              if (medicationReason == null || medicationReason.isEmpty) {
                return "Medication reason can't ne empty";
              }
              return null;
            },
            onChanged: (medicationReason) {
              medicationController.medications.value.reason = medicationReason;
            },
            decoration:
                InputDecoration(hintText: "type reason here. e.g. headache"),
          ),
        ),
        Gap(15),
        Row(
          children: [
            Text(
              "Add Medicines",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " *",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
              ),
            ),
            Gap(10),
            Icon(FluentIcons.pill_24_regular),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: MyAppColors.shadedGrey,
            borderRadius: BorderRadius.circular(borderRadius - 2),
          ),
          child: Column(
            children: <Widget>[
                  if (medicationController
                          .medications.value.medicines?.isEmpty ==
                      true)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "No medicine added yet",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ] +
                List<Widget>.generate(
                  medicationController.medications.value.medicines?.length ?? 0,
                  (index) {
                    return Row(
                      children: [
                        Icon(FluentIcons.pill_24_regular),
                        Text(
                          medicationController
                                  .medications.value.medicines?[index]
                                  .toJson() ??
                              "Empty",
                        ),
                      ],
                    );
                  },
                ),
          ),
        ),
        Gap(5),
        OutlinedButton.icon(
          onPressed: () {
            Get.to(() => AddNewMedicine());
          },
          icon: Icon(
            FluentIcons.add_24_regular,
          ),
          label: Text("Add Medicine"),
        ),
        Gap(10),
        Text(
          "Notes",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(5),
        customTextFieldDecoration(
          textFormField: TextFormField(
            controller: medicationNotesController,
            validator: (medicationNotes) {
              if (medicationNotes == null || medicationNotes.isEmpty) {
                return "Medication title can't ne empty";
              }
              return null;
            },
            onChanged: (medicationNotes) {
              medicationController.medications.value.prescription =
                  Prescription(
                imageUrl: medicationController
                    .medications.value.prescription?.imageUrl,
                notes: medicationNotes,
              );
            },
            decoration: InputDecoration(hintText: "type title here..."),
          ),
        ),
        Gap(10),
        Row(
          children: [
            Text(
              "Add Prescription Photo",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(10),
            Icon(
              FluentIcons.image_add_24_regular,
            ),
          ],
        ),
        Gap(5),
        SizedBox(
          height: 150,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: MyAppColors.shadedMutedColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: () {},
            child: Icon(
              FluentIcons.image_add_24_regular,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}

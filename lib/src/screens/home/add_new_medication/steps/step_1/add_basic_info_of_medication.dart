import 'dart:developer';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/camera/take_a_picture.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_1/add_medicine/add_medicine.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:jbl_pill_reminder_app/src/widgets/get_titles.dart';
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

  late String? medicationPrescriptionImage =
      medicationController.medications.value.prescription?.imageUrl;

  @override
  void dispose() {
    medicationNotesController.dispose();
    medicationReasonController.dispose();
    medicationTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(medicationController.medications.value.toJson().toString());
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        getTitlesForFields(
          title: "Medication Title",
          isFieldRequired: true,
          icon: FluentIcons.edit_24_regular,
        ),
        const Gap(5),
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
            decoration: const InputDecoration(hintText: "type title here..."),
          ),
        ),
        // const Gap(15),
        // getTitlesForFields(
        //   title: "Medication Reason",
        //   icon: FluentIcons.edit_24_regular,
        // ),
        // const Gap(5),
        // customTextFieldDecoration(
        //   textFormField: TextFormField(
        //     controller: medicationReasonController,
        //     onChanged: (medicationReason) {
        //       medicationController.medications.value.reason = medicationReason;
        //     },
        //     decoration: const InputDecoration(
        //         hintText: "type reason here. e.g. headache"),
        //   ),
        // ),
        const Gap(15),
        getTitlesForFields(
          title: "Add Medicines",
          isFieldRequired: true,
          icon: FluentIcons.pill_24_regular,
        ),
        Obx(
          () => Container(
            margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: MyAppColors.shadedGrey,
              borderRadius: BorderRadius.circular(borderRadius - 2),
            ),
            child: Column(
              children: <Widget>[
                    if ((medicationController.medications.value.medicines ?? [])
                            .isEmpty ==
                        true)
                      const Align(
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
                    medicationController.medications.value.medicines?.length ??
                        0,
                    (index) {
                      final current = medicationController
                          .medications.value.medicines?[index];
                      return Container(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        decoration: BoxDecoration(
                          border: Border(
                            top: index == 0
                                ? BorderSide.none
                                : BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    child: Text((index + 1).toString()),
                                  ),
                                  const Gap(10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(current?.name ?? ""),
                                          const Gap(5),
                                          Text(
                                            "( ${current?.type ?? ""})",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (current?.notes != null)
                                        Text(
                                          current?.notes ?? "",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: MyAppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Get.to(
                                      () => AddNewMedicine(
                                        medicine: current!,
                                        index: index,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.navigate_next_rounded,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ),
        ),
        const Gap(5),
        OutlinedButton.icon(
          onPressed: () {
            Get.to(
              () => AddNewMedicine(
                medicine: Medicine(),
              ),
            );
          },
          icon: const Icon(
            FluentIcons.add_24_regular,
          ),
          label: const Text("Add Medicine"),
        ),
        const Gap(10),
        getTitlesForFields(
          title: "Note",
          icon: FluentIcons.note_24_regular,
        ),
        const Gap(5),
        customTextFieldDecoration(
          textFormField: TextFormField(
            controller: medicationNotesController,
            onChanged: (medicationNotes) {
              medicationController.medications.value.prescription =
                  Prescription(
                imageUrl: medicationController
                    .medications.value.prescription?.imageUrl,
                notes: medicationNotes,
              );
            },
            decoration: const InputDecoration(hintText: "type title here..."),
          ),
        ),
        const Gap(10),
        getTitlesForFields(
          title: "Add Prescription Photo",
          icon: FluentIcons.image_add_24_regular,
        ),
        const Gap(5),
        SizedBox(
          height: medicationPrescriptionImage == null ? 150 : null,
          child: medicationPrescriptionImage != null
              ? Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        borderRadius,
                      ),
                      child: Image.file(
                        File(medicationPrescriptionImage!),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: TextButton.icon(
                        onPressed: takeAPhotoOfPrescription,
                        icon: const Icon(
                          FluentIcons.image_add_24_regular,
                          size: 18,
                        ),
                        label: const Text("Change"),
                      ),
                    ),
                  ],
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: MyAppColors.shadedMutedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  onPressed: takeAPhotoOfPrescription,
                  child: const Icon(
                    FluentIcons.image_add_24_regular,
                    size: 36,
                  ),
                ),
        ),
        const Gap(10),
        const SetMedicationSchedule()
      ],
    );
  }

  takeAPhotoOfPrescription() async {
    String? imagePath = await Get.to(
      () => const TakeAPicture(
        title: "Take picture of prescription",
      ),
    );
    if (imagePath != null) {
      setState(() {
        medicationPrescriptionImage = imagePath;
        medicationController.medications.value.prescription = Prescription(
          imageUrl: medicationPrescriptionImage,
          notes: medicationController.medications.value.prescription?.notes,
        );
      });
    }
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/camera/take_a_picture.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:jbl_pill_reminder_app/src/widgets/get_titles.dart';
import 'package:jbl_pill_reminder_app/src/widgets/textfieldinput_decoration.dart';
import 'package:toastification/toastification.dart';

import '../../../../../../theme/colors.dart';

class AddNewMedicine extends StatefulWidget {
  final Medicine? medicine;
  final int? index;
  const AddNewMedicine({super.key, required this.medicine, this.index});

  @override
  State<AddNewMedicine> createState() => _AddNewMedicineState();
}

class _AddNewMedicineState extends State<AddNewMedicine> {
  final medicationController = Get.put(AddNewMedicationController());

  late TextEditingController medicineNameController =
      TextEditingController(text: widget.medicine?.name);
  late TextEditingController notesController =
      TextEditingController(text: widget.medicine?.notes);

  @override
  void initState() {
    super.initState();
  }

  late Medicine medicine = widget.medicine ?? Medicine();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              const Gap(10),
              const Center(
                child: Text(
                  "Add New Medicine",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              const Gap(10),
              getTitlesForFields(
                title: "Medicine Name",
                isFieldRequired: true,
                icon: FluentIcons.edit_24_regular,
              ),
              const Gap(5),
              customTextFieldDecoration(
                textFormField: TextFormField(
                  controller: medicineNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Medicine name can't be empty";
                    }
                    return null;
                  },
                  onChanged: (medicineName) {
                    medicine.name = medicineName;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration:
                      const InputDecoration(hintText: "type medicine name..."),
                ),
              ),
              const Gap(10),
              getTitlesForFields(
                title: "Medicine Type",
                isFieldRequired: true,
                icon: FluentIcons.select_all_on_24_regular,
              ),
              const Gap(5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    medicineTypeList.length,
                    (index) {
                      return Container(
                        height: 30,
                        padding: const EdgeInsets.only(right: 5),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                medicine.type == medicineTypeList[index]
                                    ? MyAppColors.primaryColor
                                    : MyAppColors.shadedMutedColor,
                            foregroundColor:
                                medicine.type == medicineTypeList[index]
                                    ? Colors.white
                                    : MyAppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              medicine.type = medicineTypeList[index];
                            });
                          },
                          icon: medicine.type == medicineTypeList[index]
                              ? const Icon(
                                  Icons.done,
                                  size: 18,
                                )
                              : null,
                          label: Text(
                            medicineTypeList[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Gap(5),
              const Gap(10),
              getTitlesForFields(
                title: "Notes",
                icon: FluentIcons.note_24_regular,
              ),
              const Gap(5),
              customTextFieldDecoration(
                textFormField: TextFormField(
                  minLines: 1,
                  maxLines: 10,
                  controller: notesController,
                  onChanged: (value) {
                    medicine.notes = value;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration:
                      const InputDecoration(hintText: "type notes here..."),
                ),
              ),
              const Gap(10),
              getTitlesForFields(
                title: "Add Photo of Medicine",
                icon: FluentIcons.image_add_24_regular,
              ),
              const Gap(5),
              SizedBox(
                height: medicine.imageUrl == null ? 150 : null,
                child: medicine.imageUrl != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              borderRadius,
                            ),
                            child: Image.file(
                              File(medicine.imageUrl!),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: TextButton.icon(
                              onPressed: takeAPhotoOfMedicine,
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
                        onPressed: takeAPhotoOfMedicine,
                        child: const Icon(
                          FluentIcons.image_add_24_regular,
                          size: 36,
                        ),
                      ),
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (formKey.currentState?.validate() == true &&
                        medicine.name != null) {
                      List<Medicine> medicines =
                          medicationController.medications.value.medicines ??
                              [];
                      if (widget.index == null) {
                        medicines.add(medicine);
                      } else {
                        medicines[widget.index!] = medicine;
                      }
                      medicationController.medications.value =
                          medicationController.medications.value
                              .copyWith(medicines: medicines);
                      Get.back();
                    } else {
                      log("Not Validate");
                      if (medicine.type == null) {
                        toastification.show(
                          title: const Text("Please select medicine type"),
                          type: ToastificationType.info,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                      }
                    }
                  },
                  icon: Icon(widget.index == null
                      ? FluentIcons.add_24_regular
                      : Icons.done),
                  label: Text(widget.index == null ? "Add" : "Save Changes"),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  List<String> medicineTypeList = [
    "Tablet",
    "Pills",
    "Injection",
    "Capsule",
    "Spray",
    "Drops",
    "Inhaler",
    "Med. Solution",
    "Powder",
    "Spoon",
    "Ampoule",
    "Patches",
    "Gel",
    "Suppository",
  ];

  takeAPhotoOfMedicine() async {
    String? imagePath = await Get.to(
      () => const TakeAPicture(
        title: "Take picture of prescription",
      ),
    );
    if (imagePath != null) {
      setState(() {
        medicine.imageUrl = imagePath;
        medicationController.medications.value.prescription = Prescription(
          imageUrl: medicine.imageUrl,
          notes: medicationController.medications.value.prescription?.notes,
        );
      });
    }
  }
}

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';

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
        TextFormField(
          decoration: InputDecoration(hintText: "type title here..."),
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
        TextFormField(
          decoration:
              InputDecoration(hintText: "type reason here. e.g. headache"),
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
            color: MyAppColors.shadedMutedColor,
            borderRadius: BorderRadius.circular(borderRadius - 2),
          ),
          child: Column(
            children: <Widget>[
                  if (medicationController.medications.isEmpty)
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
                  medicationController.medications.length,
                  (index) {
                    return Row(
                      children: [
                        Icon(FluentIcons.pill_24_regular),
                        Text(
                          medicationController.medications[index].toJson(),
                        ),
                      ],
                    );
                  },
                ),
          ),
        ),
        Gap(5),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(
            FluentIcons.add_24_regular,
          ),
          label: Text("Add Medicine"),
        ),
        Gap(10),
        Row(
          children: [
            Text(
              "Add Photo",
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

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:jbl_pill_reminder_app/src/widgets/textfieldinput_decoration.dart';

import '../../../../../theme/colors.dart';

class AddNewMedicine extends StatefulWidget {
  const AddNewMedicine({super.key});

  @override
  State<AddNewMedicine> createState() => _AddNewMedicineState();
}

class _AddNewMedicineState extends State<AddNewMedicine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gap(10),
              Center(
                child: Text(
                  "Add New Medicine",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Row(
                children: [
                  Text(
                    "Medicine Name",
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
                  decoration:
                      InputDecoration(hintText: "type medicine name..."),
                ),
              ),
              Gap(10),
              Row(
                children: [
                  Text(
                    "Medicine Type",
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    medicineTypeList.length,
                    (index) {
                      return Container(
                        height: 30,
                        padding: EdgeInsets.only(right: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            medicineTypeList[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Gap(5),
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
                  minLines: 1,
                  maxLines: 10,
                  decoration: InputDecoration(hintText: "type notes here..."),
                ),
              ),
              Gap(10),
              Row(
                children: [
                  Text(
                    "Add Photo of Medicine",
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
                width: double.infinity,
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
              Gap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(FluentIcons.add_24_regular),
                  label: Text("Add"),
                ),
              ),
              Gap(20),
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
}

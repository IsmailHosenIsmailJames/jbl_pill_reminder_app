import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:jbl_pills_reminder_app/src/resources/medicine_list.dart";
import "package:jbl_pills_reminder_app/src/screens/home/controller/home_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/home/drawer/my_drawer.dart";

class MyPillsPage extends StatefulWidget {
  final String phone;
  const MyPillsPage({super.key, required this.phone});

  @override
  State<MyPillsPage> createState() => _MyPillsPageState();
}

class _MyPillsPageState extends State<MyPillsPage> {
  final HomeController homeController = Get.put(HomeController());
  late List<MedicineModel> allMedicine;
  @override
  void initState() {
    List<MedicineModel> temAllMedicine = [];
    for (var reminder in homeController.listOfAllReminder) {
      MedicineModel currentMedicine = reminder.medicine!;
      bool isAlreadyExits = false;
      for (var medicine in temAllMedicine) {
        if (medicine.brandName == currentMedicine.brandName &&
            medicine.genericName == currentMedicine.genericName &&
            medicine.brandName == currentMedicine.brandName &&
            medicine.strength == currentMedicine.strength) {
          isAlreadyExits = true;
        }
      }
      if (!isAlreadyExits) {
        temAllMedicine.add(currentMedicine);
      }
    }
    allMedicine = temAllMedicine;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        phone: widget.phone,
      ),
      appBar: AppBar(
        title: const Text("My Pills"),
      ),
      body: ListView.builder(
        itemCount: allMedicine.length,
        itemBuilder: (context, index) {
          MedicineModel medicine = allMedicine[index];
          return Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FluentIcons.pill_24_regular,
                ),
                const Gap(5),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (medicine.brandName.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pill Name :",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Gap(5),
                            Expanded(
                              child: Text(
                                medicine.brandName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (medicine.strength.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Strength :",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Gap(5),
                            Expanded(child: Text(medicine.strength)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

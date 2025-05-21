import "dart:convert";
import "dart:developer";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:hive/hive.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/home/controller/home_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart";
import "package:jbl_pills_reminder_app/src/widgets/medication_card.dart";
import "package:toastification/toastification.dart";

import "../../core/functions/safe_substring.dart";

class TakeMedicinePage extends StatefulWidget {
  final String? title;
  final String? payload;
  final ReminderModel currentMedicationToTake;
  const TakeMedicinePage({
    super.key,
    this.title,
    this.payload,
    required this.currentMedicationToTake,
  });

  @override
  State<TakeMedicinePage> createState() => _TakeMedicinePageState();
}

class _TakeMedicinePageState extends State<TakeMedicinePage> {
  final homeController = Get.put(HomeController());
  final ProfilePageController profilePageController =
      Get.put(ProfilePageController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Take Medicine"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.medication_rounded,
                      size: 50,
                    ),
                  ),
                ),
                const Gap(30),
                if (widget.currentMedicationToTake.medicine?.brandName != null)
                  Text(
                    substringSafe(
                      widget.currentMedicationToTake.medicine?.brandName ?? "",
                      30,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Divider(),
                const Text(
                  "Details: ",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ] +
              [
                cardOfReminderForSummary(
                  homeController.nextReminder.value!,
                  context,
                  showTitle: false,
                )
              ] +
              <Widget>[
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        label: const Text(
                          "Back",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () async {
                          final reminderDoneDB = Hive.box("reminder_done");
                          Map<String, dynamic> reminderData =
                              widget.currentMedicationToTake.toMap();
                          reminderData["doneBackup"] = false;
                          await reminderDoneDB.put(
                            DateTime.now().millisecondsSinceEpoch.toString(),
                            jsonEncode(reminderData),
                          );
                          try {
                            HomeController.backupReminderHistory(
                                profilePageController.userInfo.value!.phone);
                          } catch (e) {
                            log(e.toString());
                          }
                          toastification.show(
                            context: context,
                            title: const Text("Saved as done"),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 3),
                          );
                          Get.back();
                        },
                        icon: const Icon(Icons.done),
                        label: const Text("Done"),
                      ),
                    ),
                  ],
                ),
              ],
        ),
      ),
    );
  }
}

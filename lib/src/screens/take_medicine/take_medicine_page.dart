import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/core/functions/functions.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_card.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/controller/home_controller.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';

class TakeMedicinePage extends StatefulWidget {
  final String? title;
  final String? payload;
  const TakeMedicinePage({
    super.key,
    this.title,
    this.payload,
  });

  @override
  State<TakeMedicinePage> createState() => _TakeMedicinePageState();
}

class _TakeMedicinePageState extends State<TakeMedicinePage> {
  final homeController = Get.put(HomeController());
  late MedicationModel currentMedicationToTake;
  @override
  void initState() {
    currentMedicationToTake = homeController.listOfAllMedications[0];
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
                if (currentMedicationToTake.title != null)
                  Text(
                    substringSafe(
                      currentMedicationToTake.title!,
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
              List<Widget>.generate(
                homeController.listOfAllMedications.length,
                (index) {
                  return cardOfMedicineForSummary(
                    homeController.listOfAllMedications[index],
                    context,
                    showTitle: false,
                  );
                },
              ) +
              <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 35,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: MyAppColors.shadedGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                              side: BorderSide(
                                color: MyAppColors.secondaryColor
                                    .withValues(alpha: 0.5),
                              ))),
                      onPressed: () {},
                      child: const Text("Notify me 5 minutes later"),
                    ),
                  ),
                ),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Already Taken",
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
                        onPressed: () {},
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

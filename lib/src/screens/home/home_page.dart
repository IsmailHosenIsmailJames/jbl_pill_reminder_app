import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jbl_pill_reminder_app/src/core/functions/find_date_medicine.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_card.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/add_new_medication.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/controller/home_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/drawer/my_drawer.dart';
import 'package:jbl_pill_reminder_app/src/screens/take_medicine/take_medicine_page.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    List<MedicationModel> allMedication = homeController.listOfAllMedications;

    homeController.listOfTodaysMedications.value =
        findDateMedicine(allMedication, DateTime.now());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pill Reminder"),
      ),
      drawer: const MyDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: MyAppColors.shadedMutedColor,
              ),
              child: tableCalendar(),
            ),
          ),
          const Gap(20),
          const Text(
            "Next Medication",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(5),
          Obx(
            () {
              if (homeController.listOfAllMedications.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => const TakeMedicinePage());
                  },
                  child: cardOfMedicineForSummary(
                    homeController.listOfAllMedications[0],
                    context,
                    isSelectedToday: true,
                  ),
                );
              } else {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(
                      color: MyAppColors.shadedMutedColor,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No Medication Scheduled",
                      style: TextStyle(
                        fontSize: 14,
                        color: MyAppColors.secondaryColor,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const Gap(15),
          Obx(
            () => Text(
              isSameDay(homeController.selectedDay.value, DateTime.now()) ==
                      true
                  ? "Today's Medication"
                  : "Medication on ${DateFormat.yMMMMd().format(homeController.selectedDay.value)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(5),
          Obx(
            () {
              if (homeController.listOfTodaysMedications.isNotEmpty) {
                return Column(
                  children: List.generate(
                    homeController.listOfTodaysMedications.length,
                    (index) {
                      return cardOfMedicineForSummary(
                        homeController.listOfTodaysMedications[index],
                        context,
                        isSelectedToday: true,
                      );
                    },
                  ),
                );
              } else {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(
                      color: MyAppColors.shadedMutedColor,
                    ),
                  ),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/img/pills.png",
                        ),
                        opacity: 0.1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "No medication for this day",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const Gap(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "All Medications",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
                width: 50,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: MyAppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    await Get.to(() => const AddNewMedication(
                          isEditMode: false,
                        ));
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () {
              return Column(
                children: List<Widget>.generate(
                      homeController.listOfAllMedications.length,
                      (index) {
                        return cardOfMedicineForSummary(
                          homeController.listOfAllMedications[index],
                          context,
                          isEditable: true,
                        );
                      },
                    ) +
                    <Widget>[
                      if (homeController.listOfAllMedications.isEmpty)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(
                              right: 5, bottom: 5, top: 5),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage("assets/img/box_empty.png"),
                              opacity: 0.1,
                            ),
                            color: MyAppColors.shadedMutedColor,
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Empty"),
                        ),
                    ],
              );
            },
          ),
        ],
      ),
    );
  }

  TableCalendar<dynamic> tableCalendar() {
    return TableCalendar(
      onDaySelected: (selectedDay, focusedDay) {
        homeController.selectedDay.value = selectedDay;
        List<MedicationModel> todaysMedication =
            findDateMedicine(homeController.listOfAllMedications, selectedDay);

        homeController.listOfTodaysMedications.value = todaysMedication;
      },
      selectedDayPredicate: (day) {
        return isSameDay(homeController.selectedDay.value, day);
      },
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: homeController.selectedDay.value,
      currentDay: DateTime.now(),
      rowHeight: 40,
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: {
        CalendarFormat.week: 'Week',
      },
      startingDayOfWeek: StartingDayOfWeek.saturday,
      headerStyle: const HeaderStyle(
        headerPadding: EdgeInsets.zero,
        headerMargin: EdgeInsets.only(bottom: 5),
        rightChevronPadding: EdgeInsets.all(5),
        leftChevronPadding: EdgeInsets.all(5),
        titleCentered: true,
        formatButtonVisible: false,
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: isSameDay(homeController.selectedDay.value, DateTime.now())
              ? MyAppColors.primaryColor
              : MyAppColors.secondaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: MyAppColors.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

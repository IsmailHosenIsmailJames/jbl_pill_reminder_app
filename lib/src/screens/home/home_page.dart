import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/add_new_medication.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/controller/home_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/drawer/my_drawer.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final homeController = Get.put(HomeController());
  final medicationController = Get.put(AddNewMedicationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pill Reminder"),
      ),
      drawer: const MyDrawer(),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Obx(
            () => Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: MyAppColors.shadedMutedColor,
              ),
              child: TableCalendar(
                onDaySelected: (selectedDay, focusedDay) {
                  homeController.selectedDay.value = selectedDay;
                  setState(() {});
                },
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: homeController.selectedDay.value,
                selectedDayPredicate: (day) {
                  return isSameDay(homeController.selectedDay.value, day);
                },
                currentDay: DateTime.now(),
                rowHeight: 40,
                calendarFormat: CalendarFormat.week,
                availableCalendarFormats: {
                  CalendarFormat.week: 'Week',
                },
                startingDayOfWeek: StartingDayOfWeek.saturday,
                headerStyle: HeaderStyle(
                  headerPadding: EdgeInsets.zero,
                  headerMargin: EdgeInsets.only(bottom: 5),
                  rightChevronPadding: EdgeInsets.all(5),
                  leftChevronPadding: EdgeInsets.all(5),
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: isSameDay(
                            homeController.selectedDay.value, DateTime.now())
                        ? MyAppColors.primaryColor
                        : MyAppColors.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: MyAppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Gap(20),
          Obx(
            () => Text(
              isSameDay(homeController.selectedDay.value, DateTime.now()) ==
                      true
                  ? "Today's Medication"
                  : "Medication on ${DateFormat.yMMMMd().format(homeController.selectedDay.value)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Gap(5),
          Obx(
            () {
              if (homeController.listOfTodaysMedications.isNotEmpty) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      homeController.listOfTodaysMedications.length,
                      (index) {
                        return Text(
                          homeController.listOfTodaysMedications[index]
                              .toJson(),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: MyAppColors.shadedMutedColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/img/pills.png",
                      ),
                      opacity: 0.1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "No medication for this day",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          Gap(20),
          Text(
            "All Medications",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(5),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List<Widget>.generate(
                      homeController.listOfAllMedications.length,
                      (index) {
                        return Text("data");
                      },
                    ) +
                    <Widget>[
                      if (homeController.listOfAllMedications.isEmpty)
                        Container(
                          height: 150,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/img/box_empty.png"),
                              opacity: 0.1,
                            ),
                            color: MyAppColors.shadedMutedColor,
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          alignment: Alignment.center,
                          child: Text("Empty"),
                        ),
                      SizedBox(
                        height: 150,
                        width: 100,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            backgroundColor: MyAppColors.shadedMutedColor,
                          ),
                          onPressed: () {
                            Get.to(() => AddNewMedication());
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 30,
                                color: MyAppColors.primaryColor,
                              ),
                              Text(
                                "Add new",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jbl_pill_reminder_app/src/core/functions/functions.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/add_new_medication.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/add_alarm_times.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';
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
          const Gap(20),
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
                      return cardOfMedicineForSummary(index, context);
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
                  onPressed: () {
                    Get.to(() => const AddNewMedication());
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
                        return cardOfMedicineForSummary(index, context);
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

  Card cardOfMedicineForSummary(int index, BuildContext context) {
    MedicationModel currentMedication =
        homeController.listOfAllMedications[index];
    DateTime? startDate = currentMedication.schedule!.startDate;
    DateTime? endDate = currentMedication.schedule?.endDate;

    String? frequencyType = currentMedication.schedule?.frequency?.type;

    String listOfFrequencyDay = "";
    if (frequencyType == frequencyTypeList[1]) {
      int? distance = currentMedication.schedule?.frequency?.everyXDays;
      listOfFrequencyDay += (distance ?? "").toString();
    } else if (frequencyType == frequencyTypeList[2]) {
      List<String> listOfDay =
          (currentMedication.schedule?.frequency?.weekly?.days) ?? [];
      listOfFrequencyDay +=
          listOfDay.toString().replaceAll('[', '').replaceAll(']', '');
    } else if (frequencyType == frequencyTypeList[3]) {
      List<int> listOfDay =
          (currentMedication.schedule?.frequency?.monthly?.dates) ?? [];
      listOfFrequencyDay +=
          listOfDay.toString().replaceAll('[', '').replaceAll(']', '');
    } else if (frequencyType == frequencyTypeList[4]) {
      List<DateTime> listOfDay =
          (currentMedication.schedule?.frequency?.yearly?.dates) ?? [];
      for (var element in listOfDay) {
        listOfFrequencyDay += "${DateFormat.yMMMd().format(element)},";
      }
    }

    final medicine = currentMedication.medicines ?? [];

    final alarm = currentMedication.schedule?.times ?? [];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius,
          ),
          side: BorderSide(
            color: MyAppColors.shadedMutedColor,
          )),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  substringSafe("${currentMedication.title}", 35),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(
              height: 7,
              color: MyAppColors.shadedMutedColor,
            ),
            Row(
              children: [
                const Icon(
                  FluentIcons.calendar_24_regular,
                ),
                const Gap(10),
                Text(DateFormat.yMMMd().format(startDate!)),
                const Gap(5),
                const Text("to"),
                const Gap(5),
                Text(DateFormat.yMMMd().format(endDate!)),
              ],
            ),
            const Gap(7),
            Row(
              children: [
                const Icon(
                  FluentIcons.arrow_repeat_all_24_regular,
                ),
                const Gap(10),
                Text(frequencyType!),
                const Gap(10),
                if (listOfFrequencyDay.isNotEmpty)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: MyAppColors.shadedMutedColor,
                    ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        "on $listOfFrequencyDay",
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(7),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FluentIcons.pill_24_regular,
                ),
                const Gap(10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    medicine.length,
                    (index) {
                      return Row(
                        children: [
                          Text(
                            medicine[index].name ?? "",
                          ),
                          const Gap(5),
                          Text(
                            "( ${medicine[index].type ?? ""} )",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const Gap(7),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FluentIcons.clock_alarm_24_regular,
                ),
                const Gap(10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    alarm.length,
                    (index) {
                      return Row(
                        children: [
                          Text(
                            clockFormat(alarm[index].clock ?? "")
                                .format(context),
                          ),
                          const Gap(5),
                          if (alarm[index].when != null)
                            Text(
                              "( ${alarm[index].when} )",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const Gap(7),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: MyAppColors.shadedMutedColor,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {},
                    icon: Icon(
                      FluentIcons.edit_24_regular,
                      size: 18,
                      color: MyAppColors.primaryColor,
                    ),
                  ),
                  const Gap(5),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      FluentIcons.delete_24_regular,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

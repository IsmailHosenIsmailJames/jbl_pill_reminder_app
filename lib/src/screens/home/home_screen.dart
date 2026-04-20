import "dart:convert";
import "dart:developer";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/main.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/core/background/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/controller/add_new_medication_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/home/controller/home_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/home/drawer/my_drawer.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:table_calendar/table_calendar.dart";

import "../../core/functions/find_date_medicine.dart";
import "../../theme/const_values.dart";
import "../../widgets/medication_card.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/getx/auth_controller.dart";


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    loadUserData();

    homeController.reloadLocalReminders();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      await requestPermissions(context);


      // Sync latest data from server after permissions granted
      if (authController.userEntity.value != null) {
        homeController.syncRemindersFromServer(
            authController.userEntity.value!.mobile);
      }


      String? actionDataRaw = sharedPreferences.getString("actionData");
      int? actionDataTime = sharedPreferences.getInt("actionDataTime");
      if (actionDataRaw != null && actionDataTime != null) {
        if (DateTime.now().millisecondsSinceEpoch - actionDataTime < 50000) {
          customNavigation(jsonDecode(actionDataRaw));
        }
      }
      await sharedPreferences.clear();
      every1Stream().listen(
        (event) async {
          sharedPreferences = await SharedPreferences.getInstance();
          await sharedPreferences.reload();
          String? actionDataRaw = sharedPreferences.getString("actionData");
          int? actionDataTime = sharedPreferences.getInt("actionDataTime");
          if (actionDataRaw != null && actionDataTime != null) {
            int timeDiff =
                DateTime.now().millisecondsSinceEpoch - actionDataTime;

            log(timeDiff.toString(), name: "timeDiff");

            if (timeDiff.abs() < 50000) {
              customNavigation(jsonDecode(actionDataRaw));
              await sharedPreferences.remove("actionData");
              await sharedPreferences.remove("actionDataTime");
            }
          }
        },
      );
    });

    every30Stream().listen((event) async {
      homeController.nextReminder.value = getNextReminder(
        sortRemindersBasedOnCreatedDate(
            homeController.listOfTodaysReminder.value),
      );
    });

    super.initState();
  }

  Stream<int> every30Stream() {
    return Stream<int>.periodic(const Duration(seconds: 30),
        (computationCount) {
      return computationCount;
    });
  }

  Stream<int> every1Stream() {
    return Stream<int>.periodic(const Duration(seconds: 1), (computationCount) {
      return computationCount;
    });
  }

  final AuthController authController = Get.find<AuthController>();

  Future<void> loadUserData() async {
    // Note: authController already loads user profile onInit or we can trigger it here
    await authController.getUserProfile();

    if (authController.userEntity.value != null) {
      HomeController.backupReminderHistory(
          authController.userEntity.value!.mobile);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

          centerTitle: true,
          title: const Text("Pill Reminder"),
          actions: [
            Obx(() {
              if (homeController.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        drawer: const MyDrawer(),

        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Obx(
              () => Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: tableCalendar(),
                ),
              ),
            ),
            const Gap(10),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyAppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final AddNewReminderModelController
                      addNewReminderModelController =
                      Get.put(AddNewReminderModelController());
                  addNewReminderModelController.reminders.value.id =
                      (math.Random().nextInt(100000000) + 100000000).toString();
                  await context.pushNamed(Routes.addReminderRoute);
                  await homeController.reloadLocalReminders();
                  await analyzeDatabaseAndScheduleReminder();
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add New Reminder",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const Gap(10),
            Text(
              "Next Reminder",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.primaryColor,
                  ),
            ),
            const Gap(5),
            Obx(
              () {
                if (homeController.nextReminder.value != null) {
                  return GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        Routes.takeMedicineRoute,
                        extra: homeController.nextReminder.value!,
                      );
                    },
                    child: cardOfReminderForSummary(
                      homeController.nextReminder.value!,
                      context,
                      isSelectedToday: true,
                      color: MyAppColors.shadedMutedColor,
                    ),
                  );
                } else {
                  return Card(
                    elevation: 0,
                    color: MyAppColors.shadedMutedColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      side: BorderSide(
                          color: MyAppColors.shadedMutedColor, width: 1.5),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      width: double.infinity,
                      child: const Text(
                        "No upcoming reminder for today. Relax! \u{1F60A}",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                        textAlign: TextAlign.center,
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
                    ? "Today's Reminder"
                    : "Reminder on ${DateFormat.yMMMMd().format(homeController.selectedDay.value)}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MyAppColors.primaryColor,
                    ),
              ),
            ),
            const Gap(5),
            Obx(
              () {
                if (homeController.listOfTodaysReminder.isNotEmpty) {
                  return Column(
                    children: List.generate(
                      homeController.listOfTodaysReminder.length,
                      (index) {
                        return cardOfReminderForSummary(
                          homeController.listOfTodaysReminder[index],
                          context,
                          isSelectedToday: true,
                          color: Colors.blue.withValues(
                            alpha: 0.2,
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Card(
                    elevation: 0,
                    color: MyAppColors.shadedMutedColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      side: BorderSide(
                          color: MyAppColors.shadedMutedColor, width: 1.5),
                    ),
                    child: Container(
                      height: 160,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child:
                                Image.asset("assets/img/pills.png", height: 60),
                          ),
                          const Gap(15),
                          const Text(
                            "No reminder for this day",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const Gap(15),
            Text(
              "All Reminders",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.primaryColor,
                  ),
            ),
            const Gap(5),
            Obx(
              () {
                return Column(
                  children: List<Widget>.generate(
                        homeController.listOfAllReminder.length,
                        (index) {
                          return cardOfReminderForSummary(
                              homeController.listOfAllReminder[index], context,
                              isEditable: true,
                              color: Colors.orange.withValues(
                                alpha: 0.1,
                              ));
                        },
                      ) +
                      <Widget>[
                        if (homeController.listOfAllReminder.isEmpty)
                          Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(top: 5),
                            color: MyAppColors.shadedMutedColor
                                .withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                              side: BorderSide(
                                  color: MyAppColors.shadedMutedColor,
                                  width: 1.5),
                            ),
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Opacity(
                                    opacity: 0.6,
                                    child: Image.asset(
                                        "assets/img/box_empty.png",
                                        height: 60),
                                  ),
                                  const Gap(15),
                                  const Text(
                                    "No reminders found",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
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
        homeController.updateDailyReminders(selectedDay);
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
        CalendarFormat.week: "Week",
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


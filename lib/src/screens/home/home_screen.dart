import "dart:convert";
import "dart:developer";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:internet_connection_checker/internet_connection_checker.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/main.dart";
import "package:jbl_pills_reminder_app/src/core/foreground/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/add_reminder.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/controller/add_new_medication_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/schedule_model.dart";
import "package:jbl_pills_reminder_app/src/screens/home/controller/home_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/home/drawer/my_drawer.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:table_calendar/table_calendar.dart";

import "../../core/functions/find_date_medicine.dart";
import "../../theme/const_values.dart";
import "../../widgets/medication_card.dart";
import "../auth/signup/model/signup_models.dart";
import "../profile_page/controller/profile_page_controller.dart";
import "../take_medicine/take_medicine_page.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());
  final reminderDB = Hive.box("reminder_db");

  bool isLoading = false;

  Future<void> getAndSaveAllReminderFromServer() async {
    if (await InternetConnectionChecker.instance.hasConnection) {
      setState(() {
        isLoading = true;
      });
      final List<Map<String, dynamic>> reminderData =
          await HomeController.getAllRemindersFromServer(
        context,
        profilePageController.userInfo.value!.phone,
      );
      for (var reminder in reminderData) {
        ReminderModel reminderModel = ReminderModel.fromMap(reminder);
        reminderDB.put(reminderModel.id, reminderModel.toJson());
      }
      reloadAllReminderList(homeController);
      await analyzeDatabaseAndScheduleReminder();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    loadUserData();
    // checkNotificationsAction();

    getAndSaveAllReminderFromServer();
    reloadAllReminderList(homeController);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      await requestPermissions();

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

    HomeController.backupReminderHistory(
        profilePageController.userInfo.value!.phone);

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

  final userDB = Hive.box("user_db");
  final ProfilePageController profilePageController =
      Get.put(ProfilePageController());

  void loadUserData() {
    String? userInfo = userDB.get("user_info", defaultValue: null);
    profilePageController.userInfo.value =
        userInfo != null ? UserInfoModel.fromJson(userInfo) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Pill Reminder"),
        actions: [

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
        ],
      ),
      drawer: MyDrawer(
        phone: profilePageController.userInfo.value!.phone,
      ),
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
          const Gap(10),
          SizedBox(
            height: 35,
            child: ElevatedButton.icon(
              style: IconButton.styleFrom(
                backgroundColor: MyAppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              onPressed: () async {
                final AddNewReminderModelController
                    addNewReminderModelController =
                    Get.put(AddNewReminderModelController());
                addNewReminderModelController.reminders.value.id =
                    (math.Random().nextInt(100000000) + 100000000).toString();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReminder(),
                  ),
                );
                reloadAllReminderList(homeController);
                await analyzeDatabaseAndScheduleReminder();
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                "Add New Reminder",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const Gap(10),
          const Text(
            "Next Reminder",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(5),
          Obx(
            () {
              if (homeController.nextReminder.value != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakeMedicinePage(
                            currentMedicationToTake:
                                homeController.nextReminder.value!,
                          ),
                        ));
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(
                      color: MyAppColors.shadedMutedColor,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "No next reminder for today.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
                  ? "Today's Reminder"
                  : "Reminder on ${DateFormat.yMMMMd().format(homeController.selectedDay.value)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                        "No reminder for this day",
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
          const Text(
            "All Reminders",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
        List<ReminderModel> todaysMedication =
            findDateMedicine(homeController.listOfAllReminder, selectedDay);

        homeController.listOfTodaysReminder.value = todaysMedication;
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

List<ReminderModel> findMedicineForSelectedDay(
    HomeController homeController, DateTime selectedDay) {
  homeController.selectedDay.value = selectedDay;
  List<ReminderModel> todaysMedication =
      findDateMedicine(homeController.listOfAllReminder, selectedDay);

  return sortRemindersBasedOnCreatedDate(todaysMedication);
}

ReminderModel? getNextReminder(List<ReminderModel> reminderList) {
  log("nextMedicine");

  DateTime now = DateTime.now().subtract(const Duration(minutes: 5));
  List<ReminderModel> todaysMedicine = findDateMedicine(reminderList, now);

  Map<int, ReminderModel> todayReminderHave = {};

  for (ReminderModel reminder in todaysMedicine) {
    TimeModel? time = getFirstNextTime(reminder.schedule!.times!, now);
    if (time != null) {
      todayReminderHave.addAll({(time.hour * 60 + time.minute): reminder});
    }
  }
  List<int> timesList = todayReminderHave.keys.toList();
  timesList.sort();

  log(timesList.toString());
  return timesList.isEmpty ? null : todayReminderHave[timesList.first];
}

TimeModel? getFirstNextTime(List<TimeModel> listOfTime, DateTime now) {
  listOfTime.sort(
      (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
  for (TimeModel time in listOfTime) {
    if (time.hour * 60 + time.minute > now.hour * 60 + now.minute) {
      return time;
    }
  }
  return null;
}

void reloadAllReminderList(HomeController homeController) {
  final reminderDB = Hive.box("reminder_db");

  List<ReminderModel> tem = [];
  for (var element in reminderDB.values) {
    tem.add(ReminderModel.fromJson(element));
  }
  homeController.listOfAllReminder.value = sortRemindersBasedOnCreatedDate(tem);
  homeController.listOfTodaysReminder.value =
      findMedicineForSelectedDay(homeController, DateTime.now());
  homeController.nextReminder.value = getNextReminder(
    sortRemindersBasedOnCreatedDate(homeController.listOfTodaysReminder.value),
  );

  log(homeController.nextReminder.value?.toJson() ?? "Empty");
}

List<ReminderModel> sortRemindersBasedOnCreatedDate(
    List<ReminderModel> listOfReminders) {
  listOfReminders.sort(
    (a, b) => a.schedule!.startDate.compareTo(b.schedule!.startDate),
  );
  return listOfReminders;
}

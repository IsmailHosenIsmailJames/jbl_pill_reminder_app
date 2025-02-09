import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:jbl_pills_reminder_app/src/screens/add_reminder/add_reminder.dart';
import 'package:jbl_pills_reminder_app/src/screens/add_reminder/controller/add_new_medication_controller.dart';
import 'package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart';
import 'package:jbl_pills_reminder_app/src/screens/home/controller/home_controller.dart';
import 'package:jbl_pills_reminder_app/src/screens/home/home_screen.dart';
import 'package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart';
import 'package:toastification/toastification.dart';

import '../core/functions/safe_substring.dart';
import '../resources/frequency.dart';
import '../theme/colors.dart';
import '../theme/const_values.dart';

Card cardOfReminderForSummary(
  ReminderModel currentReminder,
  BuildContext context, {
  bool isSelectedToday = false,
  bool showTitle = true,
  bool isEditable = false,
  Color? color,
}) {
  DateTime? startDate = currentReminder.schedule!.startDate;
  DateTime? endDate = currentReminder.schedule?.endDate;

  String? frequencyType = currentReminder.schedule?.frequency?.type;

  String listOfFrequencyDay = '';
  if (frequencyType == frequencyTypeList[1]) {
    int? distance = currentReminder.schedule?.frequency?.everyXDays;
    listOfFrequencyDay += (distance ?? '').toString();
  } else if (frequencyType == frequencyTypeList[2]) {
    List<String> listOfDay =
        (currentReminder.schedule?.frequency?.weekly?.days) ?? [];
    listOfFrequencyDay +=
        listOfDay.toString().replaceAll('[', '').replaceAll(']', '');
  } else if (frequencyType == frequencyTypeList[3]) {
    List<int> listOfDay =
        (currentReminder.schedule?.frequency?.monthly?.dates) ?? [];
    listOfFrequencyDay +=
        listOfDay.toString().replaceAll('[', '').replaceAll(']', '');
  } else if (frequencyType == frequencyTypeList[4]) {
    List<DateTime> listOfDay =
        (currentReminder.schedule?.frequency?.yearly?.dates) ?? [];
    for (var element in listOfDay) {
      listOfFrequencyDay += '${DateFormat.yMMMd().format(element)},';
    }
  }

  final alarm = currentReminder.schedule?.times ?? [];

  return Card(
    color: color,
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius,
        ),
        side: BorderSide(
          color: isSelectedToday
              ? MyAppColors.primaryColor.withValues(alpha: 0.5)
              : MyAppColors.shadedMutedColor,
        )),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(
                    FluentIcons.pill_24_regular,
                  ),
                  const Gap(10),
                  Text(
                    substringSafe(currentReminder.medicine?.name ?? '', 35),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(5),
                  if (currentReminder.medicine?.genericName != null)
                    Text(
                      "(${currentReminder.medicine?.genericName ?? ""}",
                    ),
                  if (currentReminder.medicine?.brandName != null)
                    Text(
                      " ${currentReminder.medicine?.brandName ?? ""})",
                    ),
                ],
              ),
            ),
          const Gap(7),
          Row(
            children: [
              const Icon(
                FluentIcons.arrow_repeat_all_24_regular,
              ),
              const Gap(10),
              Text(
                frequencyType ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(10),
              if (listOfFrequencyDay.isNotEmpty)
                Container(
                  width: frequencyType == frequencyTypeList[1]
                      ? MediaQuery.of(context).size.width * 0.48
                      : MediaQuery.of(context).size.width * 0.58,
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
                      frequencyType == frequencyTypeList[1]
                          ? 'every $listOfFrequencyDay days'
                          : 'on $listOfFrequencyDay',
                    ),
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(left: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (currentReminder.quantity != null)
                      const Text('Quantity: '),
                    if (currentReminder.quantity != null)
                      Text(
                        '${currentReminder.quantity} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(5),
          Container(
            padding: const EdgeInsets.only(left: 35.0),
            child: Text(
              "${currentReminder.schedule?.howManyMinutes ?? ""} ${currentReminder.schedule?.howManyMinutes == null ? "" : "minutes "}${currentReminder.schedule?.whenToTake ?? ""}",
            ),
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
                        Text(alarm[index].name),
                        const Gap(5),
                        Text(
                          TimeOfDay(
                                  hour: alarm[index].hour,
                                  minute: alarm[index].minute)
                              .format(context),
                        ),
                        const Gap(5),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if ((currentReminder.description ?? '').isNotEmpty) const Gap(7),
          if ((currentReminder.description ?? '').isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FluentIcons.notepad_24_regular,
                ),
                const Gap(10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    currentReminder.description ?? '',
                  ),
                ),
              ],
            ),
          const Gap(7),
          Row(
            children: [
              const Icon(
                FluentIcons.calendar_24_regular,
              ),
              const Gap(10),
              Text(DateFormat.yMMMd().format(startDate)),
              const Gap(5),
              const Text('to'),
              const Gap(5),
              endDate == null
                  ? const Text('On going')
                  : Text(DateFormat.yMMMd().format(endDate)),
            ],
          ),
          const Gap(7),
          if (isEditable)
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
                    onPressed: () async {
                      final addMedicationController =
                          Get.put(AddNewReminderModelController());
                      addMedicationController.reminders.value = currentReminder;

                      await Get.to(
                        () => const AddReminder(
                          editMode: true,
                        ),
                      );
                      addMedicationController.reminders.value = ReminderModel(
                          id: (Random().nextInt(100000000) + 100000000)
                              .toString());
                      reloadAllReminderList(Get.find());
                    },
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            insetPadding: const EdgeInsets.all(10),
                            title: const Text('Are you sure?'),
                            content: const Text(
                                "Once you delete, you can't recover it again."),
                            actions: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel'),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  if (await InternetConnection()
                                          .hasInternetAccess ==
                                      false) {
                                    toastification.show(
                                      context: context,
                                      title: const Text('No internet'),
                                      autoCloseDuration:
                                          const Duration(seconds: 2),
                                      type: ToastificationType.error,
                                    );
                                    return;
                                  }
                                  String id = currentReminder.id;

                                  ProfilePageController profile = Get.find();
                                  final bool isDeleted =
                                      await HomeController.deleteReminder(
                                          profile.userInfo.value!.phone, id);
                                  if (isDeleted) {
                                    final reminderDB = Hive.box('reminder_db');
                                    await reminderDB.delete(id);
                                    final HomeController homeController =
                                        Get.find();

                                    for (var element in reminderDB.values) {
                                      homeController.listOfAllReminder
                                          .add(ReminderModel.fromJson(element));
                                    }
                                    Navigator.pop(context);

                                    reloadAllReminderList(homeController);

                                    toastification.show(
                                      context: context,
                                      title: const Text('Successfully deleted'),
                                      type: ToastificationType.success,
                                      autoCloseDuration:
                                          const Duration(seconds: 2),
                                    );
                                  } else {
                                    toastification.show(
                                      context: context,
                                      title: const Text('Failed to delete'),
                                      type: ToastificationType.error,
                                      autoCloseDuration:
                                          const Duration(seconds: 2),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                              )
                            ],
                          );
                        },
                      );
                    },
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

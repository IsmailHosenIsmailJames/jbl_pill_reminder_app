import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jbl_pill_reminder_app/src/core/functions/functions.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/schedule_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/steps/step_2/add_alarm_times.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:jbl_pill_reminder_app/src/widgets/get_titles.dart';
import 'package:jbl_pill_reminder_app/src/widgets/textfieldinput_decoration.dart';

class SetMedicationSchedule extends StatefulWidget {
  final ScheduleModel? scheduleModel;
  const SetMedicationSchedule({super.key, this.scheduleModel});

  @override
  State<SetMedicationSchedule> createState() => _SetMedicationScheduleState();
}

class _SetMedicationScheduleState extends State<SetMedicationSchedule> {
  final medicationController = Get.put(AddNewMedicationController());

  late ScheduleModel scheduleModel =
      medicationController.medications.value.schedule ??
          ScheduleModel(startDate: DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(10),
        getTitlesForFields(
          title: "Ending Date of Medication",
          isFieldRequired: true,
          icon: FluentIcons.calendar_24_regular,
        ),
        const Gap(5),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              ).then((value) {
                setState(() {
                  scheduleModel.endDate = value;
                  medicationController.medications.value.schedule =
                      scheduleModel;
                });
              });
            },
            icon: const Icon(
              FluentIcons.calendar_24_regular,
              size: 18,
            ),
            label: Text(
              scheduleModel.endDate == null
                  ? "Pick a Date"
                  : DateFormat.yMMMEd().format(scheduleModel.endDate!),
            ),
          ),
        ),
        const Gap(10),
        getTitlesForFields(
          title: "Frequency",
          icon: FluentIcons.clock_24_regular,
          isFieldRequired: true,
        ),
        const Gap(5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              frequencyTypeList.length,
              (index) {
                bool isSelected =
                    scheduleModel.frequency?.type == frequencyTypeList[index];
                return Container(
                  height: 30,
                  padding: const EdgeInsets.only(right: 5),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? MyAppColors.primaryColor
                          : MyAppColors.shadedMutedColor,
                      foregroundColor:
                          isSelected ? Colors.white : MyAppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        scheduleModel.frequency =
                            scheduleModel.frequency?.copyWith(
                                  type: frequencyTypeList[index],
                                ) ??
                                Frequency(
                                  type: frequencyTypeList[index],
                                );
                      });
                    },
                    icon: isSelected
                        ? const Icon(
                            Icons.done,
                            size: 18,
                          )
                        : null,
                    label: Text(
                      frequencyTypeList[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Gap(10),
        if (scheduleModel.frequency?.type == frequencyTypeList[1])
          customTextFieldDecoration(
            textFormField: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                scheduleModel.frequency?.everyXDays = int.tryParse(value);
              },
              decoration: const InputDecoration(
                hintText: "type how many days the gap is...",
              ),
            ),
          ),
        if (scheduleModel.frequency?.type == frequencyTypeList[2])
          getTitlesForFields(
            title: "Select Week Days",
            icon: FluentIcons.select_all_on_24_regular,
          ),
        if (scheduleModel.frequency?.type == frequencyTypeList[3])
          getTitlesForFields(
            title: "Select Days in a Month",
            icon: FluentIcons.select_all_on_24_regular,
          ),
        if (scheduleModel.frequency?.type == frequencyTypeList[4])
          getTitlesForFields(
            title: "Add Dates of a Year",
            icon: FluentIcons.calendar_24_regular,
          ),
        const Gap(5),
        if (scheduleModel.frequency?.type == frequencyTypeList[2])
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                weekDaysList.length,
                (index) {
                  List<String> selectedWeekDays =
                      scheduleModel.frequency?.weekly?.days ?? [];
                  bool isSelected =
                      selectedWeekDays.contains(weekDaysList[index]);
                  return Container(
                    height: 30,
                    padding: const EdgeInsets.only(right: 5),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? MyAppColors.primaryColor
                            : MyAppColors.shadedMutedColor,
                        foregroundColor: isSelected
                            ? Colors.white
                            : MyAppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            selectedWeekDays.remove(weekDaysList[index]);
                          } else {
                            selectedWeekDays.add(weekDaysList[index]);
                          }
                          scheduleModel.frequency?.weekly = scheduleModel
                                  .frequency?.weekly
                                  ?.copyWith(days: selectedWeekDays) ??
                              Weekly(days: selectedWeekDays);
                        });
                      },
                      icon: isSelected
                          ? const Icon(
                              Icons.done,
                              size: 18,
                            )
                          : null,
                      label: Text(
                        weekDaysList[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (scheduleModel.frequency?.type == frequencyTypeList[3])
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                31,
                (index) {
                  List<int> selectedDaysInMonth =
                      scheduleModel.frequency?.monthly?.dates ?? [];
                  bool isSelected = selectedDaysInMonth.contains(index + 1);
                  return Container(
                    height: 30,
                    padding: const EdgeInsets.only(right: 5),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? MyAppColors.primaryColor
                            : MyAppColors.shadedMutedColor,
                        foregroundColor: isSelected
                            ? Colors.white
                            : MyAppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            selectedDaysInMonth.remove(index + 1);
                          } else {
                            selectedDaysInMonth.add(index + 1);
                          }
                          scheduleModel.frequency?.monthly = scheduleModel
                                  .frequency?.monthly
                                  ?.copyWith(dates: selectedDaysInMonth) ??
                              Monthly(dates: selectedDaysInMonth);
                        });
                      },
                      icon: isSelected
                          ? const Icon(
                              Icons.done,
                              size: 18,
                            )
                          : null,
                      label: Text(
                        (index + 1).toString(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (scheduleModel.frequency?.type == frequencyTypeList[4])
          Container(
            margin:
                const EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: MyAppColors.shadedMutedColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              children: <Widget>[
                    if ((scheduleModel.frequency?.yearly?.dates ?? []).isEmpty)
                      const Row(
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            size: 12,
                          ),
                          Gap(10),
                          Text(
                            "No dates selected",
                          ),
                        ],
                      ),
                  ] +
                  List<Widget>.generate(
                    scheduleModel.frequency?.yearly?.dates?.length ?? 0,
                    (index) => Row(
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          size: 12,
                        ),
                        const Gap(10),
                        Text(
                          DateFormat.MMMEd().format(
                              scheduleModel.frequency!.yearly!.dates![index]),
                        ),
                      ],
                    ),
                  ) +
                  <Widget>[
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(DateTime.now().year, 12, 31),
                            initialDate: DateTime.now(),
                          ).then((value) {
                            setState(() {
                              if (value != null) {
                                List<DateTime> dates =
                                    scheduleModel.frequency?.yearly?.dates ??
                                        [];
                                dates.add(value);
                                scheduleModel.frequency?.yearly = scheduleModel
                                        .frequency?.yearly
                                        ?.copyWith(dates: dates) ??
                                    Yearly(dates: dates);
                              }
                            });
                          });
                        },
                        label: const Text("Add Date"),
                        icon: const Icon(
                          FluentIcons.add_24_regular,
                          size: 18,
                        ),
                      ),
                    )
                  ],
            ),
          ),
        const Gap(10),
        getTitlesForFields(
          title: "Alarm Time for Medicine",
          isFieldRequired: true,
          icon: FluentIcons.clock_alarm_24_regular,
        ),
        const Gap(5),
        Obx(
          () {
            final scheduleModel =
                medicationController.medications.value.schedule ??
                    ScheduleModel(startDate: DateTime.now());

            return Container(
              margin:
                  const EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: MyAppColors.shadedMutedColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Column(
                children: <Widget>[
                      if ((scheduleModel.times ?? []).isEmpty)
                        const Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              size: 12,
                            ),
                            Gap(10),
                            Text(
                              "No Alarm Times Added",
                            ),
                          ],
                        ),
                    ] +
                    List<Widget>.generate(
                      scheduleModel.times?.length ?? 0,
                      (index) => Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: index == 0
                                ? BorderSide.none
                                : const BorderSide(color: Colors.grey),
                          ),
                        ),
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.radio_button_checked,
                                size: 12,
                              ),
                            ),
                            const Gap(10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      clockFormat(scheduleModel
                                              .times![index].clock!)
                                          .format(context),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(10),
                                    Text(
                                      scheduleModel.times![index].when
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const Gap(10),
                                    SizedBox(
                                      height: 25,
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            iconSize: 15),
                                        onPressed: () {
                                          Get.to(
                                            () => AddAlarmTimes(
                                              time: scheduleModel.times![index],
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            iconSize: 15),
                                        onPressed: () {
                                          setState(() {
                                            scheduleModel.times
                                                ?.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (scheduleModel.times?[index].notes != null ||
                                    scheduleModel
                                            .times?[index].notes?.isNotEmpty ==
                                        true)
                                  Row(
                                    children: [
                                      Text(
                                        substringSafe(
                                          scheduleModel.times![index].notes
                                              .toString(),
                                          40,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ) +
                    <Widget>[
                      const Gap(10),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.to(() => const AddAlarmTimes());
                          },
                          label: const Text("Add Alarm Times"),
                          icon: const Icon(
                            FluentIcons.add_24_regular,
                            size: 18,
                          ),
                        ),
                      )
                    ],
              ),
            );
          },
        ),
        // const Gap(10),
        // getTitlesForFields(
        //   title: "Note",
        //   icon: FluentIcons.note_24_regular,
        // ),
        // const Gap(5),
        // customTextFieldDecoration(
        //   textFormField: TextFormField(
        //     onChanged: (value) {
        //       scheduleModel.notes = value;
        //     },
        //     decoration: const InputDecoration(hintText: "type note here..."),
        //   ),
        // ),
        const Gap(10),
      ],
    );
  }
}

List<String> weekDaysList = [
  "Saturday",
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
];

List<String> frequencyTypeList = [
  "Daily",
  "Every X Days",
  "Weekly",
  "Monthly",
  "Yearly"
];

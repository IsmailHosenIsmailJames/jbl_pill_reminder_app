import "package:dartx/dartx.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_enums.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/presentation/bloc/pill_schedule_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_enums.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/bloc/add_reminder_cubit.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_cubit.dart";

import "../theme/colors.dart";
import "../theme/const_values.dart";

Card cardOfReminder(
  ReminderEntity reminder,
  BuildContext context, {
  bool isSelectedToday = false,
  bool showTitle = true,
  Color? color,
}) {
  final schedule = reminder.pillSchedule;
  if (schedule == null) {
    return const Card(child: Text("No schedule details"));
  }

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
            Row(
              children: [
                const Icon(FluentIcons.pill_24_regular),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.medicineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (schedule.size != null) Text("${schedule.size} mg/ml"),
                  ],
                ),
              ],
            ),
          const Gap(7),
          Row(
            children: [
              const Icon(FluentIcons.clock_alarm_24_regular),
              const Gap(10),
              Builder(
                builder: (context) {
                  final timeParts = reminder.time.split(":");
                  if (timeParts.length != 2) {
                    return const Text("Scheduled for: Invalid time");
                  }
                  int hour = int.parse(timeParts[0]);
                  int minute = int.parse(timeParts[1]);

                  return Text(
                    "Scheduled for: ${TimeOfDay(hour: hour, minute: minute).format(context)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              )
            ],
          ),
          const Gap(5),
          Row(
            children: [
              const Icon(FluentIcons.calendar_24_regular),
              const Gap(10),
              Text(
                "Date: ${DateFormat.yMMMMd().format(reminder.date)}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (reminder.status != "PENDING")
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 35),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: reminder.status == ReminderStatus.TAKEN.name
                      ? Colors.green.withValues(alpha: 0.2)
                      : reminder.status == ReminderStatus.STOPPED.name
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Status: ${reminder.status}",
                  style: TextStyle(
                    color: reminder.status == ReminderStatus.TAKEN.name
                        ? Colors.green
                        : reminder.status == ReminderStatus.STOPPED.name
                            ? Colors.red
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Card cardOfReminderForSummary(
  PillScheduleEntity currentSchedule,
  BuildContext context, {
  bool isSelectedToday = false,
  bool showTitle = true,
  bool isEditable = false,
  Color? color,
}) {
  DateTime endDate = currentSchedule.endDate;
  FrequencyType frequencyType = currentSchedule.frequency;

  String listOfFrequencyDay = "";
  if (frequencyType == FrequencyType.X_DAYS) {
    listOfFrequencyDay += (currentSchedule.xDayValue ?? "").toString();
  } else if (frequencyType == FrequencyType.WEEKLY) {
    listOfFrequencyDay +=
        (currentSchedule.weeklyValues ?? []).map((e) => e.name).join(", ");
  } else if (frequencyType == FrequencyType.MONTHLY) {
    listOfFrequencyDay += (currentSchedule.monthlyDates ?? []).join(", ");
  } else if (frequencyType == FrequencyType.YEARLY) {
    for (var element in currentSchedule.yearlyDates ?? []) {
      listOfFrequencyDay += "${DateFormat.yMMMd().format(element)}, ";
    }
  }

  final alarmSlots = currentSchedule.times ?? [];

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
            Row(
              children: [
                const Icon(FluentIcons.pill_24_regular),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSchedule.medicineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (currentSchedule.size != null)
                      Text("${currentSchedule.size} mg/ml"),
                  ],
                ),
              ],
            ),
          const Gap(7),
          Row(
            children: [
              const Icon(FluentIcons.arrow_repeat_all_24_regular),
              const Gap(10),
              if (frequencyType != FrequencyType.X_DAYS)
                Text(
                  frequencyType.name
                      .replaceAll("_", " ")
                      .toLowerCase()
                      .capitalize(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (frequencyType != FrequencyType.X_DAYS) const Gap(10),
              if (listOfFrequencyDay.isNotEmpty)
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: MyAppColors.shadedMutedColor,
                    ),
                    child: Text(
                      frequencyType == FrequencyType.X_DAYS
                          ? "Every $listOfFrequencyDay day(s)"
                          : "On $listOfFrequencyDay",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(5),
          if (currentSchedule.qty != null)
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Text(
                "Quantity: ${currentSchedule.qty}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          if (currentSchedule.whenToTake != null ||
              currentSchedule.takingNotes != null)
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentSchedule.whenToTake != null)
                    Text(
                      "When to take: ${currentSchedule.whenToTake}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  if (currentSchedule.takingNotes != null)
                    Text(
                      "Notes: ${currentSchedule.takingNotes}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          const Gap(7),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(FluentIcons.clock_alarm_24_regular),
              const Gap(10),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: alarmSlots.map((slot) {
                    int hour = 0, minute = 0;
                    switch (slot) {
                      case ScheduleTimeSlot.Morning:
                        hour = int.parse(
                            currentSchedule.morningTime.split(":")[0]);
                        minute = int.parse(
                            currentSchedule.morningTime.split(":")[1]);
                        break;
                      case ScheduleTimeSlot.Afternoon:
                        hour = int.parse(
                            currentSchedule.afternoonTime.split(":")[0]);
                        minute = int.parse(
                            currentSchedule.afternoonTime.split(":")[1]);
                        break;
                      case ScheduleTimeSlot.Evening:
                        hour = int.parse(
                            currentSchedule.eveningTime.split(":")[0]);
                        minute = int.parse(
                            currentSchedule.eveningTime.split(":")[1]);
                        break;
                      case ScheduleTimeSlot.Night:
                        hour =
                            int.parse(currentSchedule.nightTime.split(":")[0]);
                        minute =
                            int.parse(currentSchedule.nightTime.split(":")[1]);
                        break;
                    }
                    return Text(
                        "${slot.name}: ${TimeOfDay(hour: hour, minute: minute).format(context)}");
                  }).toList(),
                ),
              ),
            ],
          ),
          const Gap(7),
          Row(
            children: [
              const Icon(FluentIcons.calendar_24_regular),
              const Gap(10),
              const Text("Ends on: "),
              Text(DateFormat.yMMMd().format(endDate)),
            ],
          ),
          if (isEditable)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    context
                        .read<AddReminderCubit>()
                        .updateReminder(currentSchedule);
                    context.pushNamed(
                      Routes.addReminderRoute,
                      extra: true,
                    );
                  },
                  icon: Icon(FluentIcons.edit_24_regular,
                      color: MyAppColors.primaryColor),
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(context, currentSchedule),
                  icon: const Icon(FluentIcons.delete_24_regular,
                      color: Colors.red),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

void _showDeleteDialog(BuildContext context, PillScheduleEntity schedule) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Reminder?"),
      content: const Text("Are you sure you want to delete this schedule?"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            if (schedule.id != null) {
              context.read<PillScheduleCubit>().deleteSchedule(schedule.id!);
            }
            Navigator.pop(context);
            context.read<HomeCubit>().reloadLocalReminders();
          },
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

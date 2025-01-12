import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/functions/functions.dart';
import '../../screens/home/add_new_medication/steps/step_2/add_alarm_times.dart';
import '../../screens/home/add_new_medication/steps/step_2/set_medication_schedule.dart';
import '../../theme/colors.dart';
import '../../theme/const_values.dart';
import 'medication_model.dart';

Card cardOfMedicineForSummary(
  MedicationModel currentMedication,
  BuildContext context, {
  bool isSelectedToday = false,
  bool showTitle = true,
  bool isEditable = false,
}) {
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
          color: isSelectedToday
              ? MyAppColors.primaryColor.withValues(alpha: 0.5)
              : MyAppColors.shadedMutedColor,
        )),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (showTitle)
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
          if (showTitle)
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
              Text(DateFormat.yMMMd().format(startDate)),
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
                          ? "every $listOfFrequencyDay days"
                          : "on $listOfFrequencyDay",
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
                        Text(alarm[index].timeOnDay ?? ""),
                        const Text(" at "),
                        Text(
                          clockFormat(alarm[index].clock ?? "").format(context),
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

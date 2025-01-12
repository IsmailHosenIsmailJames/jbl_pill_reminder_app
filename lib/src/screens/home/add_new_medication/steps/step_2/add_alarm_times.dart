import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/schedule_model.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/add_new_medication/controller/add_new_medication_controller.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/widgets/get_titles.dart';
import 'package:jbl_pill_reminder_app/src/widgets/textfieldinput_decoration.dart';
import 'package:toastification/toastification.dart';

class AddAlarmTimes extends StatefulWidget {
  final TimeModel? time;
  const AddAlarmTimes({super.key, this.time});

  @override
  State<AddAlarmTimes> createState() => _AddAlarmTimesState();
}

class _AddAlarmTimesState extends State<AddAlarmTimes> {
  late TimeModel timeModel = widget.time ?? TimeModel();

  final medicationController = Get.put(AddNewMedicationController());

  TextEditingController customWhenToTakeMedicine = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Map<String, int>? timeRangeOnSelectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            const Gap(10),
            const Center(
              child: Text(
                "Add New Alarm",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            const Gap(10),
            getTitlesForFields(
              title: "Alarm Time",
              isFieldRequired: true,
              icon: FluentIcons.clock_alarm_24_regular,
            ),
            const Gap(5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  medicineScheduleTimeName.length,
                  (index) {
                    String key = medicineScheduleTimeName.keys.toList()[index];
                    Map<String, int> value =
                        medicineScheduleTimeName.values.toList()[index];
                    bool isSelected = key == timeModel.timeOnDay;
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
                            timeModel.timeOnDay = key;
                            timeRangeOnSelectedDay = value;
                            int avg =
                                (value["start_time"]! + value["end_time"]!) ~/
                                    2;
                            timeModel.clock = "$avg:00";
                          });
                        },
                        icon: isSelected
                            ? const Icon(
                                Icons.done,
                                size: 18,
                              )
                            : null,
                        label: Text(
                          key,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (timeModel.clock != null)
              Row(
                children: [
                  const Text(
                    "Time:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(10),
                  Text(clockFormat(timeModel.clock!).format(context)),
                  const Gap(10),
                  TextButton(
                    onPressed: () {
                      showTimePicker(
                        context: context,
                        initialTime: timeModel.clock == null
                            ? TimeOfDay.now()
                            : clockFormat(timeModel.clock!),
                      ).then(
                        (value) {
                          if (value != null) {
                            setState(() {
                              timeModel.clock = "${value.hour}:${value.minute}";
                            });
                          }
                        },
                      );
                    },
                    child: const Text(
                      "Change",
                    ),
                  ),
                ],
              ),
            const Gap(10),
            getTitlesForFields(
              title: "When",
              icon: Icons.help_outline,
            ),
            const Gap(5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  whenTakeMedicine.length,
                  (index) {
                    bool isSelected = whenTakeMedicine[index] == timeModel.when;
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
                            timeModel.when = whenTakeMedicine[index];
                          });
                        },
                        icon: isSelected
                            ? const Icon(
                                Icons.done,
                                size: 18,
                              )
                            : null,
                        label: Text(
                          whenTakeMedicine[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (timeModel.when == whenTakeMedicine[3]) const Gap(10),
            if (timeModel.when == whenTakeMedicine[3])
              customTextFieldDecoration(
                textFormField: TextFormField(
                  controller: customWhenToTakeMedicine,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(hintText: "type here..."),
                ),
              ),
            const Gap(10),
            getTitlesForFields(
              title: "Note",
              icon: FluentIcons.note_24_regular,
            ),
            const Gap(5),
            customTextFieldDecoration(
              textFormField: TextFormField(
                decoration:
                    const InputDecoration(hintText: "type your notes here..."),
                onChanged: (value) {
                  timeModel.notes = value;
                },
              ),
            ),
            const Gap(50),
            ElevatedButton.icon(
              onPressed: () {
                if (timeModel.clock == null) {
                  toastification.show(
                    title: const Text("You need to pick a alarm time"),
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                  return;
                }
                if (timeModel.when == whenTakeMedicine[3]) {
                  timeModel =
                      timeModel.copyWith(when: customWhenToTakeMedicine.text);
                }
                List<TimeModel> times =
                    medicationController.medications.value.schedule?.times ??
                        [];
                times.add(timeModel);
                ScheduleModel scheduleModel = medicationController
                        .medications.value.schedule
                        ?.copyWith(times: times) ??
                    ScheduleModel(
                      startDate: DateTime.now(),
                      times: times,
                    );
                medicationController.medications.value =
                    medicationController.medications.value.copyWith(
                  schedule: scheduleModel,
                );
                Get.back();
              },
              icon: const Icon(
                FluentIcons.add_24_regular,
                size: 18,
              ),
              label: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

TimeOfDay clockFormat(String time) {
  List<String> splitedTime = time.split(":");
  return TimeOfDay(
      hour: int.parse(splitedTime[0]), minute: int.parse(splitedTime[1]));
}

List<String> whenTakeMedicine = [
  "After food",
  "Before food",
  "With Food",
  "Custom"
];

Map<String, Map<String, int>> medicineScheduleTimeName = {
  "Morning": {
    "start_time": 06,
    "end_time": 12,
  },
  "Afternoon": {
    "start_time": 12,
    "end_time": 16,
  },
  "Evening": {
    "start_time": 16,
    "end_time": 22,
  },
  "Night": {
    "start_time": 19,
    "end_time": 24,
  }
};

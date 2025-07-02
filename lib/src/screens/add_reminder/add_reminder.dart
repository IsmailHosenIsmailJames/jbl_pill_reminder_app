import "dart:convert";
import "dart:developer" as dev;
import "dart:math";

import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:hive/hive.dart";
import "package:http_status_code/http_status_code.dart";
import "package:internet_connection_checker/internet_connection_checker.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/resources/medicine_list.dart";
import "package:jbl_pills_reminder_app/src/resources/medicine_schedule_title_name.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/controller/add_new_medication_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/schedule_model.dart";
import "package:jbl_pills_reminder_app/src/screens/home/controller/home_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:searchfield/searchfield.dart";
import "package:toastification/toastification.dart";

import "../../resources/frequency.dart";
import "../../resources/week_days.dart";
import "../../theme/colors.dart";
import "../../theme/const_values.dart";

class AddReminder extends StatefulWidget {
  final bool? editMode;

  const AddReminder({super.key, this.editMode});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  ScrollController scrollControllerScheduleTitle = ScrollController();

  final HomeController homeController = Get.find();

  final addNewReminderModelController =
      Get.put(AddNewReminderModelController());
  late ReminderModel reminderModel =
      addNewReminderModelController.reminders.value;

  late ScheduleModel scheduleModel =
      reminderModel.schedule ?? ScheduleModel(startDate: DateTime.now());

  late TextEditingController textEditingControllerSearchMedicine =
      TextEditingController(text: reminderModel.medicine?.brandName);
  late TextEditingController textEditingControllerReminderDescription =
      TextEditingController(
    text: reminderModel.description,
  );
  late TextEditingController textEditingControllerQuantity =
      TextEditingController(
    text: reminderModel.quantity,
  );
  late TextEditingController textEditingControllerMinutes =
      TextEditingController(
    text: reminderModel.schedule?.howManyMinutes?.toString(),
  );

  final formKey = GlobalKey<FormState>();

  ProfilePageController profileController = Get.put(ProfilePageController());

  bool isAsyncLoading = false;

  List<Map<String, dynamic>> medicineData = [];

  @override
  void initState() {
    loadMedicineList();
    super.initState();
  }

  Future<void> loadMedicineList() async {
    String medicineJsonData =
        await rootBundle.loadString("assets/resources/medicine_list.json");
    dev.log("1");
    List<Map> temMedicineData = List<Map>.from(jsonDecode(medicineJsonData));
    dev.log("2");

    for (int i = 0; i < temMedicineData.length; i++) {
      Map<String, dynamic> element =
          Map<String, dynamic>.from(temMedicineData[i]);
      medicineData.add({
        "brandName": element["BN"], // brandName = BN
        "genericName": element["GN"], // genericName = GN
        "strength": element["S"], // strength = S
        "dosageDescription": element["DD"], // dosageDescription = DD
      });
    }
    dev.log("3");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reminder"),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              bottom: 100,
              top: 10,
              left: 10,
              right: 10,
            ),
            children: [
              const Gap(10),
              getTitlesForFields(title: "Medicine name", isFieldRequired: true),
              const Gap(5),
              customTextFieldDecoration(
                textFormField: SearchField<MedicineModel>(
                  onSuggestionTap: (p0) {
                    textEditingControllerSearchMedicine.text =
                        "${p0.item?.brandName ?? ''} (${p0.item?.genericName ?? ''}) - ${p0.item?.dosageDescription ?? ''}";
                  },
                  controller: textEditingControllerSearchMedicine,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please type a medicine name";
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  suggestions: medicineData.map(
                    (e) {
                      final MedicineModel item = MedicineModel.fromMap(e);
                      return SearchFieldListItem<MedicineModel>(
                        item.toJson(),
                        item: item,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(item.brandName),
                                const Gap(5),
                                Text(
                                  "(${item.genericName}) - ${item.dosageDescription}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              const Gap(10),
              getTitlesForFields(
                title: "Frequency",
                isFieldRequired: true,
              ),
              const Gap(5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    frequencyTypeList.length,
                    (index) {
                      bool isSelected = scheduleModel.frequency?.type ==
                          frequencyTypeList[index];
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
                        return "Please enter some text";
                      }
                      if (int.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                    controller: TextEditingController(
                        text: scheduleModel.frequency?.everyXDays?.toString() ??
                            ""),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      scheduleModel.frequency?.everyXDays = int.tryParse(value);
                    },
                    decoration: const InputDecoration(
                      hintText: "type how many days the gap is...",
                    ),
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
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
                        bool isSelected =
                            selectedDaysInMonth.contains(index + 1);
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
                                scheduleModel.frequency?.monthly =
                                    scheduleModel.frequency?.monthly?.copyWith(
                                            dates: selectedDaysInMonth) ??
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
                  margin: const EdgeInsets.only(
                      left: 15, top: 5, bottom: 5, right: 5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: MyAppColors.shadedMutedColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Column(
                    children: <Widget>[
                          if ((scheduleModel.frequency?.yearly?.dates ?? [])
                              .isEmpty)
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
                                DateFormat.MMMEd().format(scheduleModel
                                    .frequency!.yearly!.dates![index]),
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
                                  lastDate:
                                      DateTime(DateTime.now().year, 12, 31),
                                  initialDate: DateTime.now(),
                                ).then((value) {
                                  setState(() {
                                    if (value != null) {
                                      List<DateTime> dates = scheduleModel
                                              .frequency?.yearly?.dates ??
                                          [];
                                      dates.add(value);
                                      scheduleModel.frequency?.yearly =
                                          scheduleModel.frequency?.yearly
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

              // Quantity
              const Gap(10),
              getTitlesForFields(
                title: "Quantity",
                isFieldRequired: true,
              ),
              const Gap(5),
              customTextFieldDecoration(
                textFormField: TextFormField(
                  controller: textEditingControllerQuantity,
                  decoration: textFieldInputDecoration(
                    hint: "type quantity here...",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    reminderModel.quantity = value;
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),

              const Gap(10),
              getTitlesForFields(
                title: "When to take",
                isFieldRequired: true,
              ),
              const Gap(5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    whenTakeMedicineList.length,
                    (index) {
                      bool isSelected = scheduleModel.whenToTake ==
                          whenTakeMedicineList[index];
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
                              scheduleModel.whenToTake =
                                  whenTakeMedicineList[index];
                            });
                          },
                          icon: isSelected
                              ? const Icon(
                                  Icons.done,
                                  size: 18,
                                )
                              : null,
                          label: Text(
                            whenTakeMedicineList[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (scheduleModel.whenToTake == whenTakeMedicineList[0] ||
                  scheduleModel.whenToTake == whenTakeMedicineList[1])
                const Gap(10),
              if (scheduleModel.whenToTake == whenTakeMedicineList[0] ||
                  scheduleModel.whenToTake == whenTakeMedicineList[1])
                getTitlesForFields(
                  title:
                      "How many minutes ${scheduleModel.whenToTake == whenTakeMedicineList[1] ? "before" : "after"} food?",
                  isFieldRequired: true,
                ),
              const Gap(5),
              if (scheduleModel.whenToTake == whenTakeMedicineList[0] ||
                  scheduleModel.whenToTake == whenTakeMedicineList[1])
                customTextFieldDecoration(
                  textFormField: TextFormField(
                    controller: textEditingControllerMinutes,
                    decoration: textFieldInputDecoration(
                      hint: "type minutes here...",
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return "Please enter valid minutes";
                      } else {
                        return null;
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              const Gap(10),
              getTitlesForFields(
                title: "Time",
                isFieldRequired: true,
              ),
              const Gap(5),
              SingleChildScrollView(
                controller: scrollControllerScheduleTitle,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    medicineScheduleTimeName.length,
                    (index) {
                      String key =
                          medicineScheduleTimeName.keys.toList()[index];
                      Map<String, int> value =
                          medicineScheduleTimeName.values.toList()[index];
                      bool isSelected = false;
                      int len = scheduleModel.times?.length ?? 0;

                      for (int i = 0; i < len; i++) {
                        if (scheduleModel.times![i].name == key) {
                          isSelected = true;
                          break;
                        }
                      }
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
                            TimeOfDay avg = TimeOfDay(
                              hour: ((value["start_time"] ?? 0) +
                                      (value["end_time"] ?? 0)) ~/
                                  2,
                              minute: 0,
                            );

                            if (!isSelected) {
                              scheduleModel.times ??= [];
                              scheduleModel.times!.add(
                                TimeModel(
                                  id: Random().nextInt(100000).toString(),
                                  name: key,
                                  hour: avg.hour,
                                  minute: avg.minute,
                                ),
                              );
                            } else {
                              scheduleModel.times?.removeWhere(
                                  (element) => element.name == key);
                            }
                            setState(() {});
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
              const Gap(5),
              Column(
                children: List.generate(
                  scheduleModel.times?.length ?? 0,
                  (index) {
                    TimeModel currentTime = scheduleModel.times![index];
                    final timeOfDay = TimeOfDay(
                        hour: currentTime.hour, minute: currentTime.minute);
                    return Row(
                      children: [
                        Text("${currentTime.name}: "),
                        const Gap(5),
                        Text(
                          timeOfDay.format(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          height: 30,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                            ),
                            onPressed: () {
                              showTimePicker(
                                context: context,
                                initialTime: timeOfDay,
                              ).then(
                                (value) {
                                  if (value != null) {
                                    setState(() {
                                      scheduleModel.times?[index] = TimeModel(
                                        id: Random().nextInt(100000).toString(),
                                        name: currentTime.name,
                                        hour: value.hour,
                                        minute: value.minute,
                                      );
                                    });
                                  }
                                },
                              );
                            },
                            child: const Text(
                              "Change",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Gap(10),
              getTitlesForFields(
                title: "Ending date of reminder",
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
                title: "Notes",
              ),
              const Gap(5),
              customTextFieldDecoration(
                textFormField: TextFormField(
                  controller: textEditingControllerReminderDescription,
                  decoration: textFieldInputDecoration(
                    hint: "type reminder description here...",
                  ),
                  maxLines: 15,
                  minLines: 1,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
              const Gap(10),
              getTitlesForFields(
                title: "Reminder type",
                isFieldRequired: true,
              ),
              const Gap(5),
              customTextFieldDecoration(
                textFormField: DropdownButtonFormField(
                  decoration: textFieldInputDecoration(
                    hint: "Select reminder type",
                  ),
                  value: reminderModel.reminderType,
                  validator: (value) {
                    if (value == null) {
                      return "Please select reminder type";
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  items: [
                    DropdownMenuItem(
                      value: ReminderType.notification,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications,
                          ),
                          const Gap(10),
                          Text(ReminderType.notification.name.capitalize),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ReminderType.alarm,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.alarm,
                          ),
                          const Gap(10),
                          Text(ReminderType.alarm.name.capitalize),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      reminderModel.reminderType = value;
                    });
                  },
                ),
              ),
              const Gap(15),
              ElevatedButton.icon(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic>? selectedMedicine;
                    for (var element in medicineData) {
                      if (element["name"] ==
                          textEditingControllerSearchMedicine.text) {
                        selectedMedicine = element;
                      }
                    }
                    MedicineModel? medicineModel;
                    if (selectedMedicine != null) {
                      medicineModel = MedicineModel.fromMap(selectedMedicine);
                    }
                    reminderModel = reminderModel.copyWith(
                      description:
                          textEditingControllerReminderDescription.text,
                      medicine: MedicineModel(
                        brandName: medicineModel?.brandName ??
                            textEditingControllerSearchMedicine.text,
                        genericName: medicineModel?.genericName ?? "",
                        strength: medicineModel?.strength ?? "",
                        dosageDescription:
                            medicineModel?.dosageDescription ?? "",
                      ),
                      schedule: scheduleModel.copyWith(
                        howManyMinutes:
                            int.tryParse(textEditingControllerMinutes.text),
                      ),
                      quantity: textEditingControllerQuantity.text,
                    );
                    String? error = checkValidityOfReminder(reminderModel);
                    if (error == null) {
                      setState(() {
                        isAsyncLoading = true;
                      });
                      if (await InternetConnectionChecker
                          .instance.hasConnection) {
                        Map<String, dynamic> data = reminderModel.toMap();
                        data["phone_number"] =
                            profileController.userInfo.value!.phone;
                        if (widget.editMode == true) {
                          final bool isSuccessful =
                              await HomeController.updateReminder(
                            context,
                            profileController.userInfo.value!.phone,
                            reminderModel.id,
                            data,
                          );
                          if (isSuccessful) {
                            await Hive.box("reminder_db")
                                .put(reminderModel.id, jsonEncode(data));

                            toastification.show(
                              context: context,
                              title: const Text("Saved changes successfully"),
                              autoCloseDuration: const Duration(seconds: 2),
                              type: ToastificationType.success,
                            );
                            homeController.listOfAllReminder.removeWhere(
                                (element) => element.id == reminderModel.id);
                            homeController.listOfAllReminder.add(reminderModel);
                            Navigator.pop(context);
                          } else {
                            toastification.show(
                              context: context,
                              title: const Text("Something went wrong"),
                              autoCloseDuration: const Duration(seconds: 2),
                              type: ToastificationType.error,
                            );
                          }
                        } else {
                          final response = await addNewReminderModelController
                              .createReminder(data);
                          if (response != null &&
                              response.statusCode == StatusCode.CREATED) {
                            await Hive.box("reminder_db")
                                .put(reminderModel.id, jsonEncode(data));

                            toastification.show(
                              context: context,
                              title: const Text("Saved Successfully"),
                              autoCloseDuration: const Duration(seconds: 2),
                              type: ToastificationType.success,
                            );
                            homeController.listOfAllReminder.add(reminderModel);
                            Navigator.pop(context);
                          } else {
                            toastification.show(
                              context: context,
                              title: const Text("Something went wrong"),
                              autoCloseDuration: const Duration(seconds: 2),
                              type: ToastificationType.error,
                            );
                          }
                        }
                      } else {
                        toastification.show(
                          context: context,
                          title: const Text("No Internet Connection"),
                          autoCloseDuration: const Duration(seconds: 2),
                          type: ToastificationType.error,
                        );
                      }
                      setState(() {
                        isAsyncLoading = false;
                      });
                    } else {
                      toastification.show(
                        context: context,
                        title: Text(error),
                        autoCloseDuration: const Duration(seconds: 2),
                        type: ToastificationType.error,
                      );
                    }
                  }
                  reloadAllReminderList(homeController);
                },
                icon: isAsyncLoading
                    ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.done),
                label: Text((widget.editMode ?? false)
                    ? "Save Changes"
                    : "Add Reminder"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? checkValidityOfReminder(ReminderModel reminderModel) {
    // check frequency of medicine
    if (textEditingControllerSearchMedicine.text.trim().isEmpty) {
      return "Please enter medicine name";
    }
    final frequency = reminderModel.schedule?.frequency;
    if (frequency != null &&
        frequency.type != null &&
        (frequency.type == frequencyTypeList[0] ||
            (frequency.type == frequencyTypeList[1] &&
                frequency.everyXDays != null) ||
            (frequency.type == frequencyTypeList[2] &&
                frequency.weekly != null) ||
            (frequency.type == frequencyTypeList[3] &&
                frequency.monthly != null) ||
            (frequency.type == frequencyTypeList[4] &&
                frequency.yearly != null))) {
      dev.log("Pass frequency:${frequency.toJson()}");
    } else {
      return "Please add frequency of medicine";
    }

    // check alarms

    if (reminderModel.schedule?.times?.isNotEmpty == true) {
      dev.log("Added ${reminderModel.schedule?.times?.length}");
    } else {
      return "Please add Alarm Time";
    }

    return null;
  }
}

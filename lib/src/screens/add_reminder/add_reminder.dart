import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_enums.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/presentation/bloc/pill_schedule_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/presentation/bloc/pill_schedule_state.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/bloc/add_reminder_cubit.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_state.dart";
import "package:jbl_pills_reminder_app/src/theme/const_values.dart";
import "package:jbl_pills_reminder_app/src/widgets/get_titles.dart";
import "package:jbl_pills_reminder_app/src/widgets/textfieldinput_decoration.dart";
import "package:searchfield/searchfield.dart";
import "package:toastification/toastification.dart";

import "../../theme/colors.dart";

class AddReminder extends StatefulWidget {
  final bool? editMode;

  const AddReminder({super.key, this.editMode});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  late TextEditingController textEditingControllerSearchMedicine;
  late TextEditingController textEditingControllerNotes;
  late TextEditingController textEditingControllerQuantity;
  late TextEditingController textEditingControllerSize;

  // Local State for the draft
  String medicineName = "";
  double? qty;
  double? size;
  FrequencyType frequency = FrequencyType.DAILY;
  int? xDayValue;
  List<WeekDay> weeklyValues = [];
  List<int> monthlyDates = [];
  List<DateTime> yearlyDates = [];
  String whenToTake = "";
  String takingNotes = "";
  String notes = "";
  List<ScheduleTimeSlot> selectedSlots = [];
  String morningTime = "09:00";
  String afternoonTime = "14:00";
  String eveningTime = "19:00";
  String nightTime = "21:00";
  ReminderType reminderType = ReminderType.notification;
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  String status = "ACTIVE";

  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> medicineData = [];

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddReminderCubit>().state;
    if (draft != null) {
      medicineName = draft.medicineName;
      qty = draft.qty;
      size = draft.size;
      frequency = draft.frequency;
      xDayValue = draft.xDayValue;
      weeklyValues = List.from(draft.weeklyValues ?? []);
      monthlyDates = List.from(draft.monthlyDates ?? []);
      yearlyDates = List.from(draft.yearlyDates ?? []);
      whenToTake = draft.whenToTake ?? "";
      takingNotes = draft.takingNotes ?? "";
      notes = draft.notes ?? "";
      selectedSlots = List.from(draft.times ?? []);
      morningTime = draft.morningTime;
      afternoonTime = draft.afternoonTime;
      eveningTime = draft.eveningTime;
      nightTime = draft.nightTime;
      reminderType = draft.reminderType;
      endDate = draft.endDate;
      status = draft.status;
    }

    textEditingControllerSearchMedicine =
        TextEditingController(text: medicineName);
    textEditingControllerNotes = TextEditingController(text: takingNotes);
    textEditingControllerQuantity =
        TextEditingController(text: qty?.toString());
    textEditingControllerSize = TextEditingController(text: size?.toString());

    loadMedicineList();
  }

  Future<void> loadMedicineList() async {
    String medicineJsonData =
        await rootBundle.loadString("assets/resources/medicine_list.json");
    List<dynamic> temMedicineData = jsonDecode(medicineJsonData);
    for (var element in temMedicineData) {
      medicineData.add({
        "brandName": element["BN"],
        "genericName": element["GN"],
        "strength": element["S"],
        "dosageDescription": element["DD"],
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PillScheduleCubit, PillScheduleState>(
      listener: (context, state) {
        if (state is PillScheduleOperationSuccess) {
          toastification.show(
            context: context,
            title: Text(state.message),
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 2),
          );
          context.read<HomeCubit>().reloadLocalReminders();
          context.pop();
        } else if (state is PillScheduleError) {
          toastification.show(
            context: context,
            title: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
                widget.editMode == true ? "Edit Schedule" : "Add Schedule")),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _buildMedicineInfoCard(),
                const Gap(15),
                _buildScheduleCard(),
                const Gap(15),
                _buildExtraDetailsCard(),
                const Gap(25),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Medicine Details",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.primaryColor,
                    fontSize: 18)),
            const Gap(20),
            getTitlesForFields(title: "Medicine name", isFieldRequired: true),
            const Gap(5),
            customTextFieldDecoration(
              textFormField: SearchField<String>(
                onSuggestionTap: (p0) {
                  setState(() {
                    medicineName = p0.item!;
                    textEditingControllerSearchMedicine.text = medicineName;
                  });
                },
                controller: textEditingControllerSearchMedicine,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter medicine name"
                    : null,
                suggestions: medicineData
                    .map((e) => SearchFieldListItem<String>(e["brandName"],
                        item: e["brandName"]))
                    .toList(),
              ),
            ),
            const Gap(15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTitlesForFields(title: "Qty"),
                      const Gap(5),
                      customTextFieldDecoration(
                        textFormField: TextFormField(
                          controller: textEditingControllerQuantity,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => qty = double.tryParse(v),
                          decoration: textFieldInputDecoration(hint: "1.0"),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTitlesForFields(title: "Size (mg/ml)"),
                      const Gap(5),
                      customTextFieldDecoration(
                        textFormField: TextFormField(
                          controller: textEditingControllerSize,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => size = double.tryParse(v),
                          decoration: textFieldInputDecoration(hint: "500"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Schedule & Frequency",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.primaryColor,
                    fontSize: 18)),
            const Gap(20),
            _buildFrequencySelection(),
            const Gap(15),
            _buildSpecificFrequencyDetails(),
            const Gap(20),
            getTitlesForFields(title: "Time Slots", isFieldRequired: true),
            const Gap(5),
            _buildTimeSlotSelection(),
            const Gap(15),
            getTitlesForFields(title: "Ending Date", isFieldRequired: true),
            const Gap(5),
            _buildDatePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelection() {
    return Wrap(
      spacing: 8,
      children: FrequencyType.values.map((f) {
        bool isSelected = frequency == f;
        return ChoiceChip(
          label: Text(f.name.replaceAll("_", " ")),
          selected: isSelected,
          onSelected: (val) {
            if (val) setState(() => frequency = f);
          },
          selectedColor: MyAppColors.primaryColor,
          labelStyle:
              TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }

  Widget _buildSpecificFrequencyDetails() {
    if (frequency == FrequencyType.X_DAYS) {
      return TextFormField(
        keyboardType: TextInputType.number,
        decoration: textFieldInputDecoration(hint: "Every 'X' days").copyWith(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onChanged: (v) => xDayValue = int.tryParse(v),
      );
    }
    if (frequency == FrequencyType.WEEKLY) {
      return Wrap(
        spacing: 5,
        children: WeekDay.values.map((w) {
          bool isSel = weeklyValues.contains(w);
          return FilterChip(
            label: Text(w.name.substring(0, 3)),
            selected: isSel,
            onSelected: (val) {
              setState(() {
                if (val) {
                  weeklyValues.add(w);
                } else {
                  weeklyValues.remove(w);
                }
              });
            },
          );
        }).toList(),
      );
    }
    if (frequency == FrequencyType.MONTHLY) {
      return Wrap(
        spacing: 5,
        children: List.generate(31, (i) {
          int day = i + 1;
          bool isSel = monthlyDates.contains(day);
          return ChoiceChip(
            label: Text("$day"),
            selected: isSel,
            onSelected: (val) {
              setState(() {
                if (val) {
                  monthlyDates.add(day);
                } else {
                  monthlyDates.remove(day);
                }
              });
            },
          );
        }),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTimeSlotSelection() {
    return Column(
      children: ScheduleTimeSlot.values.map((slot) {
        bool isSel = selectedSlots.contains(slot);
        String time = "";
        if (slot == ScheduleTimeSlot.Morning) time = morningTime;
        if (slot == ScheduleTimeSlot.Afternoon) time = afternoonTime;
        if (slot == ScheduleTimeSlot.Evening) time = eveningTime;
        if (slot == ScheduleTimeSlot.Night) time = nightTime;

        var timeParts = time.split(":");
        int? hour = int.tryParse(timeParts[0]);
        int? minute = int.tryParse(timeParts[1]);

        return CheckboxListTile(
          title: Text(slot.name),
          subtitle: Text(
              "Time: ${TimeOfDay(hour: hour ?? DateTime.now().hour, minute: minute ?? DateTime.now().minute).format(context)}"),
          value: isSel,
          onChanged: (val) async {
            if (val == true) {
              final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: hour ?? DateTime.now().hour,
                      minute: minute ?? DateTime.now().minute));
              if (picked != null) {
                setState(() {
                  selectedSlots.add(slot);
                  final formatted =
                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                  if (slot == ScheduleTimeSlot.Morning) morningTime = formatted;
                  if (slot == ScheduleTimeSlot.Afternoon) {
                    afternoonTime = formatted;
                  }
                  if (slot == ScheduleTimeSlot.Evening) eveningTime = formatted;
                  if (slot == ScheduleTimeSlot.Night) nightTime = formatted;
                });
              }
            } else {
              setState(() => selectedSlots.remove(slot));
            }
          },
          activeColor: MyAppColors.primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return OutlinedButton.icon(
      onPressed: () async {
        final d = await showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030));
        if (d != null) setState(() => endDate = d);
      },
      icon: const Icon(Icons.calendar_today),
      label: Text(DateFormat.yMMMd().format(endDate)),
    );
  }

  Widget _buildExtraDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Additional Info",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.primaryColor,
                    fontSize: 18)),
            const Gap(15),
            customTextFieldDecoration(
              textFormField: DropdownButtonFormField<ReminderType>(
                initialValue: reminderType,
                items: ReminderType.values
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(r.name.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => reminderType = v!),
              ),
            ),
            const Gap(15),
            customTextFieldDecoration(
              textFormField: DropdownButtonFormField<String>(
                value: whenToTake.isEmpty ? null : whenToTake,
                hint: const Text("When to take?"),
                items: [
                  "Before Meal",
                  "After Meal",
                  "With Meal",
                  "Empty Stomach"
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => whenToTake = v ?? ""),
              ),
            ),
            const Gap(15),
            customTextFieldDecoration(
              textFormField: TextFormField(
                controller: textEditingControllerNotes,
                maxLines: 3,
                onChanged: (v) {
                  takingNotes = v;
                  notes = v; // Setting both to keep it simple
                },
                decoration: textFieldInputDecoration(
                    hint: "Notes about taking this medicine..."),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<PillScheduleCubit, PillScheduleState>(
      builder: (context, state) {
        bool isLoading = state is PillScheduleLoading;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: MyAppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.editMode == true ? "SAVE CHANGES" : "ADD REMINDER",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _submit() {
    if (formKey.currentState!.validate()) {
      if (selectedSlots.isEmpty) {
        toastification.show(
            context: context,
            title: const Text("Select at least one time slot"),
            type: ToastificationType.warning);
        return;
      }

      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        toastification.show(
            context: context,
            title: const Text("User not authenticated"),
            type: ToastificationType.error);
        return;
      }

      final draft = context.read<AddReminderCubit>().state;

      final entity = PillScheduleEntity(
        id: draft?.id,
        userId: authState.user.id, // Using user ID from auth cubit
        medicineName: textEditingControllerSearchMedicine.text,
        qty: qty,
        size: size,
        frequency: frequency,
        xDayValue: xDayValue,
        weeklyValues: weeklyValues,
        monthlyDates: monthlyDates,
        yearlyDates: yearlyDates,
        whenToTake: whenToTake,
        takingNotes: takingNotes,
        notes: notes,
        times: selectedSlots,
        morningTime: morningTime,
        afternoonTime: afternoonTime,
        eveningTime: eveningTime,
        nightTime: nightTime,
        reminderType: reminderType,
        endDate: endDate,
        status: status,
      );

      if (widget.editMode == true && entity.id != null) {
        context.read<PillScheduleCubit>().updateSchedule(entity.id!, entity);
      } else {
        context.read<PillScheduleCubit>().createSchedule(entity);
      }
    }
  }
}

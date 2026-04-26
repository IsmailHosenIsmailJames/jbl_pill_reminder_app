import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_enums.dart";
import "package:jbl_pills_reminder_app/src/widgets/medication_card.dart";
import "package:toastification/toastification.dart";

import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/presentation/bloc/reminder_cubit.dart";
import "package:jbl_pills_reminder_app/src/core/functions/dependency_injection.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/presentation/bloc/reminder_state.dart";

class TakeMedicinePage extends StatefulWidget {
  final String? title;
  final String? payload;
  final PillScheduleEntity? currentMedicationToTake;
  final ReminderEntity? reminder;
  final int? alarmID;

  const TakeMedicinePage({
    super.key,
    this.title,
    this.payload,
    this.currentMedicationToTake,
    this.reminder,
    this.alarmID,
  });

  @override
  State<TakeMedicinePage> createState() => _TakeMedicinePageState();
}

class _TakeMedicinePageState extends State<TakeMedicinePage> {
  late PillScheduleEntity schedule;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null && widget.reminder!.pillSchedule != null) {
      schedule = widget.reminder!.pillSchedule!;
    } else if (widget.currentMedicationToTake != null) {
      schedule = widget.currentMedicationToTake!;
    } else {
      // Fallback or error handling
      schedule = PillScheduleEntity(
        userId: 0,
        medicineName: "Unknown",
        frequency: FrequencyType.DAILY,
        endDate: DateTime(2030),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ReminderCubit>(),
        child: BlocListener<ReminderCubit, ReminderState>(
            listener: (context, state) {
              if (state is ReminderOperationSuccess) {
                context.pop();
              } else if (state is ReminderError) {
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
                title: Text(widget.title ?? "Take Medicine"),
              ),
              body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.medication_rounded, size: 50),
                      ),
                    ),
                    const Gap(30),
                    Text(
                      schedule.medicineName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    const Text("Details: ", style: TextStyle(fontSize: 14)),
                    cardOfReminderForSummary(
                      schedule,
                      context,
                      showTitle: false,
                    ),
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                            ),
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Back"),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                            ),
                            onPressed: () async {
                              if (widget.reminder != null) {
                                context.read<ReminderCubit>().updateReminder(
                                  widget.reminder!.id,
                                  {"status": "TAKEN"},
                                );
                              } else {
                                // Logic for marking as done can be added here (intake history)
                                toastification.show(
                                  context: context,
                                  title: const Text("Marked as taken"),
                                  type: ToastificationType.success,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );

                                if (widget.currentMedicationToTake?.id !=
                                    null) {
                                  try {
                                    AwesomeNotifications().dismiss(
                                        widget.currentMedicationToTake!.id!);
                                  } catch (_) {}
                                }

                                context.pop();
                              }
                            },
                            icon: const Icon(Icons.done),
                            label: const Text("Done"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }
}

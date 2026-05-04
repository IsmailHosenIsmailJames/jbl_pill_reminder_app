import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/core/functions/dependency_injection.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/widgets/medication_card.dart";
import "bloc/all_reminder_cubit.dart";
import "bloc/all_reminder_state.dart";

class AllReminderPage extends StatelessWidget {
  final String phone;
  const AllReminderPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AllReminderCubit>()..fetchAllReminders(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Reminders"),
        ),
        body: BlocBuilder<AllReminderCubit, AllReminderState>(
          builder: (context, state) {
            if (state is AllReminderLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AllReminderLoaded) {
              if (state.allReminders.isEmpty) {
                return const Center(
                  child: Text("No reminders found"),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.allReminders.length,
                itemBuilder: (context, index) {
                  final reminder = state.allReminders[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${index + 1}.",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            "${reminder.time},",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(5),
                          Text(
                            DateFormat.yMMMMEEEEd().format(reminder.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Gap(5),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            Routes.takeMedicineRoute,
                            extra: reminder,
                          );
                        },
                        child: cardOfReminder(reminder, context),
                      ),
                      const Gap(15),
                    ],
                  );
                },
              );
            } else if (state is AllReminderError) {
              return Center(
                child: Text("Error: ${state.message}"),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_cubit.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_state.dart";
import "package:jbl_pills_reminder_app/src/widgets/medication_card.dart";

class AllSchedulesPage extends StatelessWidget {
  final String phone;

  const AllSchedulesPage({
    super.key,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Schedules"),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final schedules = state.listOfAllReminder;

          if (schedules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Image.asset("assets/img/box_empty.png", height: 80),
                    ),
                    const Gap(20),
                    const Text(
                      "No schedules found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<HomeCubit>().reloadLocalReminders();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final isExpired = schedule.endDate.isBefore(today);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      cardOfReminderForSummary(
                        schedule,
                        context,
                        isEditable: true,
                        color: isExpired
                            ? Colors.grey.withValues(alpha: 0.05)
                            : Colors.orange.withValues(alpha: 0.08),
                      ),
                      if (isExpired)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Outdated",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

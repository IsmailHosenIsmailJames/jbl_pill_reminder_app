import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/core/functions/dependency_injection.dart";
import "package:jbl_pills_reminder_app/src/widgets/medication_card.dart";
import "bloc/history_cubit.dart";
import "bloc/history_state.dart";

class HistoryPage extends StatelessWidget {
  final String phone;
  const HistoryPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HistoryCubit>()..fetchHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My History"),
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HistoryLoaded) {
              if (state.history.isEmpty) {
                return const Center(
                  child: Text("No history found"),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final reminder = state.history[index];
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
                      cardOfReminder(reminder, context),
                      const Gap(15),
                    ],
                  );
                },
              );
            } else if (state is HistoryError) {
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


import "package:dartx/dartx.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_enums.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/screens/home/drawer/my_drawer.dart";

class MyPillsPage extends StatefulWidget {
  final String phone;
  const MyPillsPage({super.key, required this.phone});

  @override
  State<MyPillsPage> createState() => _MyPillsPageState();
}

class _MyPillsPageState extends State<MyPillsPage> {
  late List<PillScheduleEntity> uniquePills;

  @override
  void initState() {
    super.initState();
    _extractUniquePills();
  }

  void _extractUniquePills() {
    List<PillScheduleEntity> tempPills = [];
    final homeCubit = context.read<HomeCubit>();
    for (var schedule in homeCubit.state.listOfAllReminder) {
      bool alreadyExists = tempPills.any((p) =>
          p.medicineName == schedule.medicineName && p.size == schedule.size);
      if (!alreadyExists) {
        tempPills.add(schedule);
      }
    }
    uniquePills = tempPills;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("My Pills"),
      ),
      body: ListView.builder(
        itemCount: uniquePills.length,
        itemBuilder: (context, index) {
          final pill = uniquePills[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(FluentIcons.pill_24_regular),
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pill.medicineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pill.size != null) ...[
                        const Gap(4),
                        Text(
                          "Size: ${pill.size} mg/ml",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const Gap(4),
                      Row(
                        children: [
                          if (pill.frequency != FrequencyType.X_DAYS)
                            Text(
                              pill.frequency.name
                                  .replaceAll("_", " ")
                                  .toLowerCase()
                                  .capitalize(),
                            ),
                          if (pill.frequency != FrequencyType.X_DAYS)
                            const Gap(10),
                          if (pill.frequency == FrequencyType.X_DAYS
                              ? (pill.xDayValue ?? 0) > 0
                              : (pill.frequency == FrequencyType.WEEKLY
                                  ? (pill.weeklyValues ?? []).isNotEmpty
                                  : (pill.frequency == FrequencyType.MONTHLY
                                      ? (pill.monthlyDates ?? []).isNotEmpty
                                      : (pill.yearlyDates ?? []).isNotEmpty)))
                            Expanded(
                              child: Text(
                                pill.frequency == FrequencyType.X_DAYS
                                    ? "Every ${pill.xDayValue} day(s)"
                                    : "On ${() {
                                        if (pill.frequency ==
                                            FrequencyType.WEEKLY) {
                                          return pill.weeklyValues
                                              ?.map((e) => e.name
                                                  .toLowerCase()
                                                  .capitalize())
                                              .join(", ");
                                        } else if (pill.frequency ==
                                            FrequencyType.MONTHLY) {
                                          return pill.monthlyDates?.join(", ");
                                        } else if (pill.frequency ==
                                            FrequencyType.YEARLY) {
                                          return pill.yearlyDates
                                              ?.map((e) =>
                                                  DateFormat.yMMMd().format(e))
                                              .join(", ");
                                        }
                                      }()}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

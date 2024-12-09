import 'package:flutter/material.dart';

class SetMedicationSchedule extends StatefulWidget {
  const SetMedicationSchedule({super.key});

  @override
  State<SetMedicationSchedule> createState() => _SetMedicationScheduleState();
}

class _SetMedicationScheduleState extends State<SetMedicationSchedule> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text("Schedule under dev"),
        ],
      ),
    );
  }
}

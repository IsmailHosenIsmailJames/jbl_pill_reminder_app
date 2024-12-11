import 'package:flutter/material.dart';

class SetMedicationSchedule extends StatefulWidget {
  const SetMedicationSchedule({super.key});

  @override
  State<SetMedicationSchedule> createState() => _SetMedicationScheduleState();
}

class _SetMedicationScheduleState extends State<SetMedicationSchedule> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        Row(
          children: [
            Text(
              "Medication Title",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " *",
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

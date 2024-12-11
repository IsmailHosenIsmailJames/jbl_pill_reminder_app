import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Widget getTitlesForFields(
    {required String title, IconData? icon, bool isFieldRequired = false}) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (isFieldRequired)
        const Text(
          " *",
          style: TextStyle(
            color: Colors.red,
            fontSize: 15,
          ),
        ),
      const Gap(10),
      if (icon != null)
        Icon(
          icon,
          size: 18,
        ),
    ],
  );
}

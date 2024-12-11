import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Widget getTitlesForFields(
    {required String title, IconData? icon, bool isFieldRequired = false}) {
  return Row(
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (isFieldRequired)
        Text(
          " *",
          style: TextStyle(
            color: Colors.red,
            fontSize: 15,
          ),
        ),
      Gap(10),
      if (icon != null)
        Icon(
          icon,
          size: 18,
        ),
    ],
  );
}

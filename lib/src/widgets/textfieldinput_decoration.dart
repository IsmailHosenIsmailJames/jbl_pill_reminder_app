import 'package:flutter/material.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';

InputDecoration textFieldInputDecoration({
  String? hint,
  String? label,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    border: InputBorder.none,
    hintText: hint,
    labelText: label,
    alignLabelWithHint: true,
    floatingLabelAlignment: FloatingLabelAlignment.center,
    suffix: suffixIcon,
  );
}

Widget customTextFieldDecoration({
  required TextFormField textFormField,
}) {
  return Container(
    padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
    decoration: BoxDecoration(
      color: MyAppColors.shadedMutedColor,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: textFormField,
  );
}

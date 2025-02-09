import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/const_values.dart';

InputDecoration textFieldInputDecoration({
  String? hint,
  String? label,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    border: InputBorder.none,
    hintText: hint,
    labelText: label,
    hintStyle: TextStyle(color: Colors.grey.shade600),
    alignLabelWithHint: true,
    floatingLabelAlignment: FloatingLabelAlignment.center,
    suffix: suffixIcon,
  );
}

Widget customTextFieldDecoration({
  required Widget textFormField,
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

import "package:flutter/material.dart";

TimeOfDay clockFormat(String time) {
  List<String> splitedTime = time.split(":");
  return TimeOfDay(
      hour: int.parse(splitedTime[0]), minute: int.parse(splitedTime[1]));
}

import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_enums.dart";

List<PillScheduleEntity> findDateMedicine(
    List<PillScheduleEntity> listOfSchedules, DateTime date) {
  List<PillScheduleEntity> todaysSchedules = [];
  for (PillScheduleEntity schedule in listOfSchedules) {
    if (schedule.endDate.isBefore(DateTime(date.year, date.month, date.day))) {
      continue;
    }

    bool isMatch = false;

    // everyday
    if (schedule.frequency == FrequencyType.DAILY) {
      isMatch = true;
    }
    // every X days
    else if (schedule.frequency == FrequencyType.X_DAYS && schedule.xDayValue != null) {
      // Assuming created_at or some start date is needed. 
      // For now using end date as a baseline for distance or just daily if data is missing
      // Realistically we need a startDate from the backend, but it's not in the schema.
      // I'll assume Daily for now or use a default start date if missing.
      isMatch = true; 
    }
    // weekly
    else if (schedule.frequency == FrequencyType.WEEKLY && schedule.weeklyValues != null) {
      DateFormat formatter = DateFormat("EEEE");
      String weekdayStr = formatter.format(date);
      // Map WeekDay enum to string
      if (schedule.weeklyValues!.any((wd) => wd.name.toLowerCase() == weekdayStr.toLowerCase())) {
        isMatch = true;
      }
    }
    // monthly
    else if (schedule.frequency == FrequencyType.MONTHLY && schedule.monthlyDates != null) {
      if (schedule.monthlyDates!.contains(date.day)) {
        isMatch = true;
      }
    }
    // yearly
    else if (schedule.frequency == FrequencyType.YEARLY && schedule.yearlyDates != null) {
      for (var element in schedule.yearlyDates!) {
        if (element.year == date.year &&
            element.month == date.month &&
            element.day == date.day) {
          isMatch = true;
          break;
        }
      }
    }

    if (isMatch) {
      todaysSchedules.add(schedule);
    }
  }
  return todaysSchedules;
}

List<PillScheduleEntity> findMedicineForSelectedDay(
    List<PillScheduleEntity> listOfAllSchedules, DateTime selectedDay) {
  return findDateMedicine(listOfAllSchedules, selectedDay);
}

PillScheduleEntity? getNextReminder(List<PillScheduleEntity> scheduleList) {
  DateTime now = DateTime.now().subtract(const Duration(minutes: 5));
  List<PillScheduleEntity> todaysSchedules = findDateMedicine(scheduleList, now);

  PillScheduleEntity? next;
  int minDiff = 24 * 60; // minutes in day

  for (var schedule in todaysSchedules) {
    for (var slot in schedule.times ?? []) {
      String timeStr = "";
      switch (slot) {
        case ScheduleTimeSlot.Morning:
          timeStr = schedule.morningTime;
          break;
        case ScheduleTimeSlot.Afternoon:
          timeStr = schedule.afternoonTime;
          break;
        case ScheduleTimeSlot.Evening:
          timeStr = schedule.eveningTime;
          break;
        case ScheduleTimeSlot.Night:
          timeStr = schedule.nightTime;
          break;
      }
      
      if (timeStr.isNotEmpty) {
        final parts = timeStr.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final totalMinutes = hour * 60 + minute;
        final nowMinutes = now.hour * 60 + now.minute;
        
        if (totalMinutes > nowMinutes && totalMinutes - nowMinutes < minDiff) {
          minDiff = totalMinutes - nowMinutes;
          next = schedule;
        }
      }
    }
  }
  return next;
}


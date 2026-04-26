import "package:equatable/equatable.dart";
import "pill_schedule_enums.dart";

class PillScheduleEntity extends Equatable {
  final int? id;
  final int userId;
  final String medicineName;
  final double? size;
  final double? qty;
  final FrequencyType frequency;
  final int? xDayValue;
  final List<WeekDay>? weeklyValues;
  final List<int>? monthlyDates;
  final List<DateTime>? yearlyDates;
  final String? whenToTake;
  final String? takingNotes;
  final List<ScheduleTimeSlot>? times;
  final String morningTime;
  final String afternoonTime;
  final String eveningTime;
  final String nightTime;
  final ReminderType reminderType;
  final String? notes;
  final DateTime endDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PillScheduleEntity({
    this.id,
    required this.userId,
    required this.medicineName,
    this.size,
    this.qty,
    required this.frequency,
    this.xDayValue,
    this.weeklyValues,
    this.monthlyDates,
    this.yearlyDates,
    this.whenToTake,
    this.takingNotes,
    this.times,
    this.morningTime = "09:00",
    this.afternoonTime = "14:00",
    this.eveningTime = "19:00",
    this.nightTime = "21:00",
    this.reminderType = ReminderType.notification,
    this.notes,
    required this.endDate,
    this.status = "ACTIVE",
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        medicineName,
        size,
        qty,
        frequency,
        xDayValue,
        weeklyValues,
        monthlyDates,
        yearlyDates,
        whenToTake,
        takingNotes,
        times,
        morningTime,
        afternoonTime,
        eveningTime,
        nightTime,
        reminderType,
        notes,
        endDate,
        status,
        createdAt,
        updatedAt,
      ];
}

import "package:dartx/dartx.dart";
import "package:intl/intl.dart";
import "../../domain/entities/pill_schedule_entity.dart";
import "../../domain/entities/pill_schedule_enums.dart";

class PillScheduleModel extends PillScheduleEntity {
  const PillScheduleModel({
    super.id,
    required super.userId,
    required super.medicineName,
    super.size,
    super.qty,
    required super.frequency,
    super.xDayValue,
    super.weeklyValues,
    super.monthlyDates,
    super.yearlyDates,
    super.whenToTake,
    super.takingNotes,
    super.times,
    super.morningTime,
    super.afternoonTime,
    super.eveningTime,
    super.nightTime,
    super.reminderType,
    super.notes,
    required super.endDate,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory PillScheduleModel.fromEntity(PillScheduleEntity entity) {
    return PillScheduleModel(
      id: entity.id,
      userId: entity.userId,
      medicineName: entity.medicineName,
      size: entity.size,
      qty: entity.qty,
      frequency: entity.frequency,
      xDayValue: entity.xDayValue,
      weeklyValues: entity.weeklyValues,
      monthlyDates: entity.monthlyDates,
      yearlyDates: entity.yearlyDates,
      whenToTake: entity.whenToTake,
      takingNotes: entity.takingNotes,
      times: entity.times,
      morningTime: entity.morningTime,
      afternoonTime: entity.afternoonTime,
      eveningTime: entity.eveningTime,
      nightTime: entity.nightTime,
      reminderType: entity.reminderType,
      notes: entity.notes,
      endDate: entity.endDate,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory PillScheduleModel.fromJson(Map<String, dynamic> json) {
    return PillScheduleModel(
      id: json["id"],
      userId: json["userId"] ?? 0,
      medicineName: json["medicineName"] ?? "",
      size: json["size"]?.toString().toDouble(),
      qty: json["qty"]?.toString().toDouble(),
      frequency: json["frequency"] != null
          ? FrequencyType.values.byName(json["frequency"])
          : FrequencyType.DAILY,
      xDayValue: json["xDayValue"],
      weeklyValues: (json["weeklyValues"] as List?)
          ?.map((e) => WeekDay.values.byName(e))
          .toList(),
      monthlyDates: (json["monthlyDates"] as List?)?.cast<int>(),
      yearlyDates: (json["yearlyDates"] as List?)
          ?.map((e) =>
              DateTime.tryParse(e.toString()) ??
              DateFormat("MM-dd-yyyy").parse(e.toString()))
          .toList(),
      whenToTake: json["whenToTake"],
      takingNotes: json["takingNotes"],
      times: (json["times"] as List?)
          ?.map((e) => ScheduleTimeSlot.values.byName(e))
          .toList(),
      morningTime: json["morningTime"] ?? "09:00",
      afternoonTime: json["afternoonTime"] ?? "14:00",
      eveningTime: json["eveningTime"] ?? "19:00",
      nightTime: json["nightTime"] ?? "21:00",
      reminderType: json["reminderType"] != null
          ? ReminderType.values.byName(json["reminderType"])
          : ReminderType.notification,
      notes: json["notes"],
      endDate: DateTime.tryParse(json["endDate"].toString()) ??
          DateFormat("MM-dd-yyyy").parse(json["endDate"].toString()),
      status: json["status"] ?? "ACTIVE",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "userId": userId,
      "medicineName": medicineName,
      "size": size,
      "qty": qty,
      "frequency": frequency.name,
      "xDayValue": xDayValue,
      "weeklyValues": weeklyValues?.map((e) => e.name).toList() ?? [],
      "monthlyDates": monthlyDates ?? [],
      "yearlyDates":
          yearlyDates?.map((e) => e.toUtc().toIso8601String()).toList() ?? [],
      "whenToTake": whenToTake ?? "",
      "takingNotes": takingNotes ?? "",
      "times": times?.map((e) => e.name).toList() ?? [],
      "morningTime": morningTime,
      "afternoonTime": afternoonTime,
      "eveningTime": eveningTime,
      "nightTime": nightTime,
      "reminderType": reminderType.name,
      "notes": notes ?? "",
      "endDate": endDate.toUtc().toIso8601String(),
      "status": status,
      if (createdAt != null) "createdAt": createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toUtc().toIso8601String(),
    };
  }
}

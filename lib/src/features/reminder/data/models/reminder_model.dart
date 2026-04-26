import "package:jbl_pills_reminder_app/src/features/pill_schedule/data/models/pill_schedule_model.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";

class ReminderModel extends ReminderEntity {
  const ReminderModel({
    required super.id,
    required super.userId,
    required super.scheduleId,
    required super.date,
    required super.time,
    required super.isRead,
    required super.action,
    required super.status,
    super.createdAt,
    super.updatedAt,
    super.pillSchedule,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json["id"],
      userId: json["userId"],
      scheduleId: json["scheduleId"],
      date: DateTime.parse(json["date"]),
      time: json["time"],
      isRead: json["isRead"] ?? false,
      action: json["action"] ?? "pending",
      status: json["status"] ?? "PENDING",
      createdAt:
          json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      pillSchedule: json["PillSchedule"] != null
          ? PillScheduleModel.fromJson(json["PillSchedule"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "scheduleId": scheduleId,
      "date": date.toUtc().toIso8601String(),
      "time": time,
      "isRead": isRead,
      "action": action,
      "status": status,
      if (createdAt != null) "createdAt": createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toUtc().toIso8601String(),
      if (pillSchedule != null)
        "PillSchedule": PillScheduleModel.fromEntity(pillSchedule!).toJson(),
    };
  }
}

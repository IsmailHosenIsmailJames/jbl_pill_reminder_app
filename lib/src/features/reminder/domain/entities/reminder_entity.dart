import "package:equatable/equatable.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";

class ReminderEntity extends Equatable {
  final int id;
  final int userId;
  final int scheduleId;
  final DateTime date;
  final String time;
  final bool isRead;
  final String action;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PillScheduleEntity? pillSchedule;

  const ReminderEntity({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.date,
    required this.time,
    required this.isRead,
    required this.action,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.pillSchedule,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        scheduleId,
        date,
        time,
        isRead,
        action,
        status,
        createdAt,
        updatedAt,
        pillSchedule,
      ];
}

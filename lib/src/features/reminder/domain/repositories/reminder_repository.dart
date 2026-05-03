import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";

abstract class ReminderRepository {
  Future<void> createReminder(Map<String, dynamic> data);
  Future<List<ReminderEntity>> getAllReminders({String? status, bool? isNextReminders, String? date});
  Future<ReminderEntity> getReminderById(int id);
  Future<void> updateReminder(int id, Map<String, dynamic> data);
  Future<void> deleteReminder(int id);
}

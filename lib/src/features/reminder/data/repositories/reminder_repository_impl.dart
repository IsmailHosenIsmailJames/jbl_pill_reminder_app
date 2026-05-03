import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/repositories/reminder_repository.dart";

import "../../data/datasources/reminder_remote_data_source.dart";

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource remoteDataSource;

  ReminderRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createReminder(Map<String, dynamic> data) async {
    await remoteDataSource.createReminder(data);
  }

  @override
  Future<List<ReminderEntity>> getAllReminders(
      {String? status, bool? isNextReminders}) async {
    return await remoteDataSource.getAllReminders(
        status: status, isNextReminders: isNextReminders);
  }

  @override
  Future<ReminderEntity> getReminderById(int id) async {
    return await remoteDataSource.getReminderById(id);
  }

  @override
  Future<void> updateReminder(int id, Map<String, dynamic> data) async {
    await remoteDataSource.updateReminder(id, data);
  }

  @override
  Future<void> deleteReminder(int id) async {
    await remoteDataSource.deleteReminder(id);
  }
}

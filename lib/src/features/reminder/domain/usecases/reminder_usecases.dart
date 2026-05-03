import "../repositories/reminder_repository.dart";
import "../entities/reminder_entity.dart";

class CreateReminderUseCase {
  final ReminderRepository repository;
  CreateReminderUseCase(this.repository);

  Future<void> call(Map<String, dynamic> data) {
    return repository.createReminder(data);
  }
}

class GetAllRemindersUseCase {
  final ReminderRepository repository;
  GetAllRemindersUseCase(this.repository);

  Future<List<ReminderEntity>> call({String? status, bool? isNextReminders}) {
    return repository.getAllReminders(
        status: status, isNextReminders: isNextReminders);
  }
}

class GetReminderByIdUseCase {
  final ReminderRepository repository;
  GetReminderByIdUseCase(this.repository);

  Future<ReminderEntity> call(int id) {
    return repository.getReminderById(id);
  }
}

class UpdateReminderUseCase {
  final ReminderRepository repository;
  UpdateReminderUseCase(this.repository);

  Future<void> call(int id, Map<String, dynamic> data) {
    return repository.updateReminder(id, data);
  }
}

class DeleteReminderUseCase {
  final ReminderRepository repository;
  DeleteReminderUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteReminder(id);
  }
}

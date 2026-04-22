import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/repositories/pill_schedule_repository.dart";

class DeletePillScheduleUseCase {
  final PillScheduleRepository repository;

  DeletePillScheduleUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deletePillSchedule(id);
  }
}

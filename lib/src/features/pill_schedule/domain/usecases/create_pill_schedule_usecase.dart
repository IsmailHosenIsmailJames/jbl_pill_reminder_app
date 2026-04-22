import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/repositories/pill_schedule_repository.dart";
import "../entities/pill_schedule_entity.dart";

class CreatePillScheduleUseCase {
  final PillScheduleRepository repository;

  CreatePillScheduleUseCase(this.repository);

  Future<void> call(PillScheduleEntity schedule) {
    return repository.createPillSchedule(schedule);
  }
}

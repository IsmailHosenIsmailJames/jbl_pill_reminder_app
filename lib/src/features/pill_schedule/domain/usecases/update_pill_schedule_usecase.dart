import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/repositories/pill_schedule_repository.dart";
import "../entities/pill_schedule_entity.dart";

class UpdatePillScheduleUseCase {
  final PillScheduleRepository repository;

  UpdatePillScheduleUseCase(this.repository);

  Future<void> call(int id, PillScheduleEntity schedule) {
    return repository.updatePillSchedule(id, schedule);
  }
}

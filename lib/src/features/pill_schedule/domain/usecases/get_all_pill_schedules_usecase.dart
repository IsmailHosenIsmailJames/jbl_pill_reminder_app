import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/repositories/pill_schedule_repository.dart";
import "../entities/pill_schedule_entity.dart";

class GetAllPillSchedulesUseCase {
  final PillScheduleRepository repository;

  GetAllPillSchedulesUseCase(this.repository);

  Future<List<PillScheduleEntity>> call() {
    return repository.getAllPillSchedules();
  }
}

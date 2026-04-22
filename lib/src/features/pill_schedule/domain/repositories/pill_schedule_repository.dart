import "../entities/pill_schedule_entity.dart";

abstract class PillScheduleRepository {
  Future<void> createPillSchedule(PillScheduleEntity schedule);
  Future<void> updatePillSchedule(int id, PillScheduleEntity schedule);
  Future<List<PillScheduleEntity>> getAllPillSchedules();
  Future<PillScheduleEntity> getPillScheduleById(int id);
  Future<void> deletePillSchedule(int id);
}

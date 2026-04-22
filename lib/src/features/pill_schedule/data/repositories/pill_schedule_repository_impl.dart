import "../../domain/entities/pill_schedule_entity.dart";
import "../../domain/repositories/pill_schedule_repository.dart";
import "../datasources/pill_schedule_remote_data_source.dart";
import "../models/pill_schedule_model.dart";

class PillScheduleRepositoryImpl implements PillScheduleRepository {
  final PillScheduleRemoteDataSource remoteDataSource;

  PillScheduleRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createPillSchedule(PillScheduleEntity schedule) async {
    await remoteDataSource.createPillSchedule(PillScheduleModel.fromEntity(schedule));
  }

  @override
  Future<void> updatePillSchedule(int id, PillScheduleEntity schedule) async {
    await remoteDataSource.updatePillSchedule(id, PillScheduleModel.fromEntity(schedule));
  }

  @override
  Future<List<PillScheduleEntity>> getAllPillSchedules() async {
    return await remoteDataSource.getAllPillSchedules();
  }

  @override
  Future<PillScheduleEntity> getPillScheduleById(int id) async {
    return await remoteDataSource.getPillScheduleById(id);
  }

  @override
  Future<void> deletePillSchedule(int id) async {
    await remoteDataSource.deletePillSchedule(id);
  }
}

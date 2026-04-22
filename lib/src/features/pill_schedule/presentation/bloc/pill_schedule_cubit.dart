import "package:flutter_bloc/flutter_bloc.dart";
import "../../domain/usecases/create_pill_schedule_usecase.dart";
import "../../domain/usecases/delete_pill_schedule_usecase.dart";
import "../../domain/usecases/get_all_pill_schedules_usecase.dart";
import "../../domain/usecases/update_pill_schedule_usecase.dart";
import "../bloc/pill_schedule_state.dart";
import "../../domain/entities/pill_schedule_entity.dart";

class PillScheduleCubit extends Cubit<PillScheduleState> {
  final CreatePillScheduleUseCase createUseCase;
  final GetAllPillSchedulesUseCase getAllUseCase;
  final UpdatePillScheduleUseCase updateUseCase;
  final DeletePillScheduleUseCase deleteUseCase;

  PillScheduleCubit({
    required this.createUseCase,
    required this.getAllUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  }) : super(PillScheduleInitial());

  Future<void> createSchedule(PillScheduleEntity schedule) async {
    emit(PillScheduleLoading());
    try {
      await createUseCase(schedule);
      emit(const PillScheduleOperationSuccess("Schedule created successfully"));
      await getSchedules();
    } catch (e) {
      emit(PillScheduleError(e.toString()));
    }
  }

  Future<void> getSchedules() async {
    emit(PillScheduleLoading());
    try {
      final schedules = await getAllUseCase();
      emit(PillScheduleLoaded(schedules));
    } catch (e) {
      emit(PillScheduleError(e.toString()));
    }
  }

  Future<void> updateSchedule(int id, PillScheduleEntity schedule) async {
    emit(PillScheduleLoading());
    try {
      await updateUseCase(id, schedule);
      emit(const PillScheduleOperationSuccess("Schedule updated successfully"));
      await getSchedules();
    } catch (e) {
      emit(PillScheduleError(e.toString()));
    }
  }

  Future<void> deleteSchedule(int id) async {
    emit(PillScheduleLoading());
    try {
      await deleteUseCase(id);
      emit(const PillScheduleOperationSuccess("Schedule deleted successfully"));
      await getSchedules();
    } catch (e) {
      emit(PillScheduleError(e.toString()));
    }
  }
}

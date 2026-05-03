import "dart:developer";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/core/functions/find_date_medicine.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/usecases/get_all_pill_schedules_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/usecases/reminder_usecases.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_state.dart";

class HomeCubit extends Cubit<HomeState> {
  final GetAllPillSchedulesUseCase _getAllUseCase;
  final GetAllRemindersUseCase _getAllRemindersUseCase;

  HomeCubit({
    required GetAllPillSchedulesUseCase getAllUseCase,
    required GetAllRemindersUseCase getAllRemindersUseCase,
  })  : _getAllUseCase = getAllUseCase,
        _getAllRemindersUseCase = getAllRemindersUseCase,
        super(HomeState(selectedDay: DateTime.now()));

  void updateSelectedDay(DateTime date) {
    emit(state.copyWith(selectedDay: date));
    _updateDailyReminders(date);
  }

  Future<void> reloadLocalReminders() async {
    emit(state.copyWith(isLoading: true));
    try {
      final schedules = await _getAllUseCase();
      final nextReminders = await _getAllRemindersUseCase(
        status: "PENDING",
        isNextReminders: true,
      );

      emit(state.copyWith(
        listOfAllReminder: schedules,
        nextReminder: nextReminders.isNotEmpty ? nextReminders.first : null,
        isLoading: false,
      ));
      _updateDailyReminders(state.selectedDay);
    } catch (e) {
      log("reloadLocalReminders error: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  void _updateDailyReminders(DateTime date) {
    log("updateDailyReminders for $date");
    final todaysMedication = findDateMedicine(state.listOfAllReminder, date);

    emit(state.copyWith(
      listOfTodaysReminder: todaysMedication,
    ));
  }

  Future<void> syncRemindersFromServer(String phoneNumber) async {
    // In Clean Architecture, the use case should handle getting the latest data.
    // For now, we reuse reloadLocalReminders which calls the use case.
    await reloadLocalReminders();
  }

  static Future<void> backupReminderHistory(String phone) async {
    log("backupReminderHistory");
    // History backup logic might eventually need its own feature, but leaving for now as per current state.
  }
}

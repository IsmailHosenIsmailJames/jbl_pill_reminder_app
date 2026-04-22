import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/core/background/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/core/functions/find_date_medicine.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/usecases/get_all_pill_schedules_usecase.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_state.dart";

class HomeCubit extends Cubit<HomeState> {
  final LocalDbRepository _localDb;
  final GetAllPillSchedulesUseCase _getAllUseCase;

  HomeCubit({
    required LocalDbRepository localDb,
    required GetAllPillSchedulesUseCase getAllUseCase,
  })  : _localDb = localDb,
        _getAllUseCase = getAllUseCase,
        super(HomeState(selectedDay: DateTime.now()));

  void updateSelectedDay(DateTime date) {
    emit(state.copyWith(selectedDay: date));
    _updateDailyReminders(date);
  }

  Future<void> reloadLocalReminders() async {
    // With the new API, we fetch from the server or local source via use case.
    // Assuming the use case handles the abstraction.
    emit(state.copyWith(isLoading: true));
    // try {
    final schedules = await _getAllUseCase();
    emit(state.copyWith(listOfAllReminder: schedules, isLoading: false));
    _updateDailyReminders(state.selectedDay);
    // } catch (e) {
    //   log("reloadLocalReminders error: $e");
    //   emit(state.copyWith(isLoading: false));
    // }
  }

  void _updateDailyReminders(DateTime date) {
    log("updateDailyReminders for $date");
    final todaysMedication = findDateMedicine(state.listOfAllReminder, date);
    final nextRem = getNextReminder(state.listOfAllReminder);

    emit(state.copyWith(
      listOfTodaysReminder: todaysMedication,
      nextReminder: nextRem,
    ));
  }

  Future<void> syncRemindersFromServer(String phoneNumber) async {
    // In Clean Architecture, the use case should handle getting the latest data.
    // For now, we reuse reloadLocalReminders which calls the use case.
    await reloadLocalReminders();

    if (await AwesomeNotifications().isNotificationAllowed()) {
      await analyzeDatabaseAndScheduleReminder();
    }
  }

  static Future<void> backupReminderHistory(String phone) async {
    log("backupReminderHistory");
    // History backup logic might eventually need its own feature, but leaving for now as per current state.
  }
}

import "dart:developer";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/usecases/get_all_pill_schedules_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/usecases/reminder_usecases.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_state.dart";
import "package:table_calendar/table_calendar.dart";

class HomeCubit extends Cubit<HomeState> {
  final GetAllPillSchedulesUseCase _getAllUseCase;
  final GetAllRemindersUseCase _getAllRemindersUseCase;

  HomeCubit({
    required GetAllPillSchedulesUseCase getAllUseCase,
    required GetAllRemindersUseCase getAllRemindersUseCase,
  })  : _getAllUseCase = getAllUseCase,
        _getAllRemindersUseCase = getAllRemindersUseCase,
        super(HomeState(selectedDay: DateTime.now()));

  Future<void> updateSelectedDay(DateTime date) async {
    emit(state.copyWith(selectedDay: date));
    await _updateDailyReminders(date);
  }

  Future<void> reloadLocalReminders() async {
    emit(state.copyWith(isLoading: true));
    try {
      final schedules = await _getAllUseCase();

      emit(state.copyWith(
        listOfAllReminder: schedules,
      ));
      await _updateDailyReminders(state.selectedDay);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      log("reloadLocalReminders error: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _updateDailyReminders(DateTime date) async {
    log("updateDailyReminders for $date");
    try {
      final dateString = DateFormat("yyyy-MM-dd").format(date);
      final reminders = await _getAllRemindersUseCase(
        date: dateString,
        status: "PENDING",
      );

      // Derive next reminder from today's list if it's the current day
      ReminderEntity? nextRem = state.nextReminder;
      if (isSameDay(date, DateTime.now())) {
        nextRem = reminders.isNotEmpty ? reminders.first : null;
      }

      emit(state.copyWith(
        listOfTodaysReminder: reminders,
        nextReminder: nextRem,
      ));
    } catch (e) {
      log("Error fetching daily reminders: $e");
    }
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

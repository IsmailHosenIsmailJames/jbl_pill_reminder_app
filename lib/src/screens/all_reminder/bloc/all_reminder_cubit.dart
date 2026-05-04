import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/usecases/reminder_usecases.dart";
import "all_reminder_state.dart";

class AllReminderCubit extends Cubit<AllReminderState> {
  final GetAllRemindersUseCase getAllRemindersUseCase;

  AllReminderCubit({required this.getAllRemindersUseCase})
      : super(AllReminderInitial());

  Future<void> fetchAllReminders() async {
    emit(AllReminderLoading());
    try {
      final allReminders = await getAllRemindersUseCase();
      // Sort reminders by date descending
      allReminders.sort((a, b) => b.date.compareTo(a.date));
      emit(AllReminderLoaded(allReminders));
    } catch (e) {
      emit(AllReminderError(e.toString()));
    }
  }
}

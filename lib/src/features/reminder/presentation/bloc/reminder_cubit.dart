import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";
import "../../domain/usecases/reminder_usecases.dart";
import "reminder_state.dart";

class ReminderCubit extends Cubit<ReminderState> {
  final CreateReminderUseCase createReminderUseCase;
  final GetAllRemindersUseCase getAllRemindersUseCase;
  final GetReminderByIdUseCase getReminderByIdUseCase;
  final UpdateReminderUseCase updateReminderUseCase;
  final DeleteReminderUseCase deleteReminderUseCase;

  ReminderCubit({
    required this.createReminderUseCase,
    required this.getAllRemindersUseCase,
    required this.getReminderByIdUseCase,
    required this.updateReminderUseCase,
    required this.deleteReminderUseCase,
  }) : super(ReminderInitial());

  Future<void> createReminder(Map<String, dynamic> data) async {
    emit(ReminderLoading());
    try {
      await createReminderUseCase(data);
      emit(const ReminderOperationSuccess("Reminder created successfully"));
      await getReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> getReminders() async {
    emit(ReminderLoading());
    try {
      final reminders = await getAllRemindersUseCase();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> getReminderById(int id) async {
    emit(ReminderLoading());
    try {
      final reminder = await getReminderByIdUseCase(id);
      emit(ReminderSingleLoaded(reminder));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> updateReminder(int id, Map<String, dynamic> data) async {
    emit(ReminderLoading());
    try {
      await updateReminderUseCase(id, data);
      Fluttertoast.showToast(msg: "Successful!");

      emit(const ReminderOperationSuccess("Reminder updated successfully"));
      await getReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> deleteReminder(int id) async {
    emit(ReminderLoading());
    try {
      await deleteReminderUseCase(id);
      emit(const ReminderOperationSuccess("Reminder deleted successfully"));
      await getReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
}

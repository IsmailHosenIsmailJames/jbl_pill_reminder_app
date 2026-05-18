import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/usecases/reminder_usecases.dart";
import "history_state.dart";

class HistoryCubit extends Cubit<HistoryState> {
  final GetAllRemindersUseCase getAllRemindersUseCase;

  HistoryCubit({required this.getAllRemindersUseCase}) : super(HistoryInitial());

  Future<void> fetchHistory() async {
    emit(HistoryLoading());
    try {
      // Fetch completed/history statuses in parallel
      final results = await Future.wait([
        getAllRemindersUseCase(status: "SENT"),
        getAllRemindersUseCase(status: "TAKEN"),
        getAllRemindersUseCase(status: "STOPPED"),
      ]);
      final history = [...results[0], ...results[1], ...results[2]];
      // Sort history by date descending
      history.sort((a, b) => b.date.compareTo(a.date));
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}

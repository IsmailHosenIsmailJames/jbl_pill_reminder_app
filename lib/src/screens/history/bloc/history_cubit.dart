import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/usecases/reminder_usecases.dart";
import "history_state.dart";

class HistoryCubit extends Cubit<HistoryState> {
  final GetAllRemindersUseCase getAllRemindersUseCase;

  HistoryCubit({required this.getAllRemindersUseCase}) : super(HistoryInitial());

  Future<void> fetchHistory() async {
    emit(HistoryLoading());
    try {
      final history = await getAllRemindersUseCase();
      // Sort history by date descending
      history.sort((a, b) => b.date.compareTo(a.date));
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}

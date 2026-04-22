import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";

class AddReminderCubit extends Cubit<PillScheduleEntity?> {
  AddReminderCubit() : super(null);

  void updateReminder(PillScheduleEntity schedule) {
    emit(schedule);
  }

  void resetReminder() {
    emit(null);
  }
}


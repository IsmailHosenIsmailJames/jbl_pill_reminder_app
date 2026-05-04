import "package:equatable/equatable.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";

abstract class AllReminderState extends Equatable {
  const AllReminderState();

  @override
  List<Object?> get props => [];
}

class AllReminderInitial extends AllReminderState {}

class AllReminderLoading extends AllReminderState {}

class AllReminderLoaded extends AllReminderState {
  final List<ReminderEntity> allReminders;
  const AllReminderLoaded(this.allReminders);

  @override
  List<Object?> get props => [allReminders];
}

class AllReminderError extends AllReminderState {
  final String message;
  const AllReminderError(this.message);

  @override
  List<Object?> get props => [message];
}

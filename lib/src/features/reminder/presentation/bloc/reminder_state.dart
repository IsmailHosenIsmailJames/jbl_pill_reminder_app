import "package:equatable/equatable.dart";
import "../../domain/entities/reminder_entity.dart";

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<ReminderEntity> reminders;
  const ReminderLoaded(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class ReminderSingleLoaded extends ReminderState {
  final ReminderEntity reminder;
  const ReminderSingleLoaded(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class ReminderError extends ReminderState {
  final String message;
  const ReminderError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReminderOperationSuccess extends ReminderState {
  final String message;
  const ReminderOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

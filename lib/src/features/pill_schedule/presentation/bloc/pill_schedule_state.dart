import "package:equatable/equatable.dart";
import "../../domain/entities/pill_schedule_entity.dart";

abstract class PillScheduleState extends Equatable {
  const PillScheduleState();

  @override
  List<Object?> get props => [];
}

class PillScheduleInitial extends PillScheduleState {}

class PillScheduleLoading extends PillScheduleState {}

class PillScheduleLoaded extends PillScheduleState {
  final List<PillScheduleEntity> schedules;
  const PillScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class PillScheduleOperationSuccess extends PillScheduleState {
  final String message;
  const PillScheduleOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PillScheduleError extends PillScheduleState {
  final String message;
  const PillScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

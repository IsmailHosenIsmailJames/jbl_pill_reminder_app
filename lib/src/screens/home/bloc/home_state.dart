import "package:equatable/equatable.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";

class HomeState extends Equatable {
  final DateTime selectedDay;
  final bool isLoading;
  final PillScheduleEntity? nextReminder;
  final List<PillScheduleEntity> listOfTodaysReminder;
  final List<PillScheduleEntity> listOfAllReminder;

  const HomeState({
    required this.selectedDay,
    this.isLoading = false,
    this.nextReminder,
    this.listOfTodaysReminder = const [],
    this.listOfAllReminder = const [],
  });

  HomeState copyWith({
    DateTime? selectedDay,
    bool? isLoading,
    PillScheduleEntity? nextReminder,
    List<PillScheduleEntity>? listOfTodaysReminder,
    List<PillScheduleEntity>? listOfAllReminder,
  }) {
    return HomeState(
      selectedDay: selectedDay ?? this.selectedDay,
      isLoading: isLoading ?? this.isLoading,
      nextReminder: nextReminder ?? this.nextReminder,
      listOfTodaysReminder: listOfTodaysReminder ?? this.listOfTodaysReminder,
      listOfAllReminder: listOfAllReminder ?? this.listOfAllReminder,
    );
  }

  @override
  List<Object?> get props => [
        selectedDay,
        isLoading,
        nextReminder,
        listOfTodaysReminder,
        listOfAllReminder,
      ];
}


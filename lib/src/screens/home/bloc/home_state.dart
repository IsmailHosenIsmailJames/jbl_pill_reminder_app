import 'package:equatable/equatable.dart';
import 'package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart';

class HomeState extends Equatable {
  final DateTime selectedDay;
  final bool isLoading;
  final ReminderModel? nextReminder;
  final List<ReminderModel> listOfTodaysReminder;
  final List<ReminderModel> listOfAllReminder;

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
    ReminderModel? nextReminder,
    List<ReminderModel>? listOfTodaysReminder,
    List<ReminderModel>? listOfAllReminder,
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

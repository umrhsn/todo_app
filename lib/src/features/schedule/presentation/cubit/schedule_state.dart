// presentation/cubit/schedule_state.dart
part of 'schedule_cubit.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleTasksLoaded extends ScheduleState {
  final ScheduleDay scheduleDay;
  final DateTime selectedDate;

  const ScheduleTasksLoaded(this.scheduleDay, this.selectedDate);

  @override
  List<Object> get props => [scheduleDay, selectedDate];
}

class ScheduleWeekLoaded extends ScheduleState {
  final Map<String, List<Task>> tasksByDate;
  final DateTime startOfWeek;

  const ScheduleWeekLoaded(this.tasksByDate, this.startOfWeek);

  @override
  List<Object> get props => [tasksByDate, startOfWeek];
}

class ScheduleDateChanged extends ScheduleState {
  final DateTime date;

  const ScheduleDateChanged(this.date);

  @override
  List<Object> get props => [date];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object> get props => [message];
}

// presentation/cubit/board_state.dart
part of 'board_cubit.dart';

abstract class BoardState extends Equatable {
  const BoardState();

  @override
  List<Object> get props => [];
}

class BoardInitial extends BoardState {}

class BoardLoading extends BoardState {}

class BoardTasksLoaded extends BoardState {
  final List<Task> tasks;
  final BoardTabType currentTab;

  const BoardTasksLoaded(this.tasks, this.currentTab);

  @override
  List<Object> get props => [tasks, currentTab];
}

class BoardTabChanged extends BoardState {
  final BoardTabType tabType;

  const BoardTabChanged(this.tabType);

  @override
  List<Object> get props => [tabType];
}

class BoardTaskDeleted extends BoardState {
  final int taskId;

  const BoardTaskDeleted(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class BoardError extends BoardState {
  final String message;

  const BoardError(this.message);

  @override
  List<Object> get props => [message];
}

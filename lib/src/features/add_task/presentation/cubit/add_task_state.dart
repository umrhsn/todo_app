// presentation/cubit/add_task_state.dart
part of 'add_task_cubit.dart';

abstract class AddTaskState extends Equatable {
  const AddTaskState();

  @override
  List<Object> get props => [];
}

class AddTaskInitial extends AddTaskState {}

class AddTaskLoading extends AddTaskState {}

class AddTaskLoaded extends AddTaskState {
  final List<Task> tasks;

  const AddTaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class AddTaskError extends AddTaskState {
  final String message;

  const AddTaskError(this.message);

  @override
  List<Object> get props => [message];
}

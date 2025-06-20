// ========== Fixed db_state.dart ==========
part of 'db_cubit.dart';

abstract class DatabaseState extends Equatable {
  const DatabaseState();

  @override
  List<Object> get props => [];
}

class DatabaseInitial extends DatabaseState {}

class DatabaseInitialized extends DatabaseState {}

class DatabaseOpened extends DatabaseState {}

class DatabaseLoading extends DatabaseState {}

class DatabaseTasksLoaded extends DatabaseState {
  final List<Task> tasks;

  const DatabaseTasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class DatabaseTasksFetched extends DatabaseState {}

class DatabaseTaskCreated extends DatabaseState {
  final Task task;

  const DatabaseTaskCreated(this.task);

  @override
  List<Object> get props => [task];
}

class DatabaseTaskUpdated extends DatabaseState {
  final Task task;

  const DatabaseTaskUpdated(this.task);

  @override
  List<Object> get props => [task];
}

class DatabaseTaskDeleted extends DatabaseState {
  final int taskId;

  const DatabaseTaskDeleted(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class DatabaseError extends DatabaseState {
  final String message;

  const DatabaseError(this.message);

  @override
  List<Object> get props => [message];
}

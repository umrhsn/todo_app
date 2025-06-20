// presentation/cubit/add_task_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/create_task_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/delete_task_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_all_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_completion_use_case.dart';

part 'add_task_state.dart';

class AddTaskCubit extends Cubit<AddTaskState> {
  final GetAllTasksUseCase getAllTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskCompletionUseCase updateTaskCompletionUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  AddTaskCubit({
    required this.getAllTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskCompletionUseCase,
    required this.deleteTaskUseCase,
  }) : super(AddTaskInitial());

  Future<void> loadAllTasks() async {
    try {
      emit(AddTaskLoading());
      final tasks = await getAllTasksUseCase();
      emit(AddTaskLoaded(tasks));
    } catch (e) {
      emit(AddTaskError(e.toString()));
    }
  }

  Future<void> createTask(Task task) async {
    try {
      emit(AddTaskLoading());
      await createTaskUseCase(task);
      await loadAllTasks(); // Refresh the list
    } catch (e) {
      emit(AddTaskError(e.toString()));
    }
  }

  Future<void> toggleTaskCompletion(int id, bool isCompleted) async {
    try {
      await updateTaskCompletionUseCase(id, isCompleted);
      await loadAllTasks(); // Refresh the list
    } catch (e) {
      emit(AddTaskError(e.toString()));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      emit(AddTaskLoading());
      await deleteTaskUseCase(id);
      await loadAllTasks(); // Refresh the list
    } catch (e) {
      emit(AddTaskError(e.toString()));
    }
  }
}

// presentation/cubit/board_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/delete_task_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_all_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_completed_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_favorite_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_uncompleted_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_completion_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_favorite_use_case.dart';

part 'board_state.dart';

enum BoardTabType { all, completed, uncompleted, favorite }

class BoardCubit extends Cubit<BoardState> {
  final GetAllTasksUseCase getAllTasksUseCase;
  final GetCompletedTasksUseCase getCompletedTasksUseCase;
  final GetUncompletedTasksUseCase getUncompletedTasksUseCase;
  final GetFavoriteTasksUseCase getFavoriteTasksUseCase;
  final UpdateTaskCompletionUseCase updateTaskCompletionUseCase;
  final UpdateTaskFavoriteUseCase updateTaskFavoriteUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  BoardCubit({
    required this.getAllTasksUseCase,
    required this.getCompletedTasksUseCase,
    required this.getUncompletedTasksUseCase,
    required this.getFavoriteTasksUseCase,
    required this.updateTaskCompletionUseCase,
    required this.updateTaskFavoriteUseCase,
    required this.deleteTaskUseCase,
  }) : super(BoardInitial());

  static BoardCubit get(context) => BlocProvider.of<BoardCubit>(context);

  BoardTabType currentTab = BoardTabType.all;
  List<Task> currentTasks = [];

  // Load tasks based on current tab
  Future<void> loadTasks() async {
    switch (currentTab) {
      case BoardTabType.all:
        await loadAllTasks();
        break;
      case BoardTabType.completed:
        await loadCompletedTasks();
        break;
      case BoardTabType.uncompleted:
        await loadUncompletedTasks();
        break;
      case BoardTabType.favorite:
        await loadFavoriteTasks();
        break;
    }
  }

  Future<void> loadAllTasks() async {
    try {
      emit(BoardLoading());
      currentTab = BoardTabType.all;
      final tasks = await getAllTasksUseCase();
      currentTasks = tasks;
      emit(BoardTasksLoaded(tasks, currentTab));
    } catch (e) {
      emit(BoardError(e.toString()));
    }
  }

  Future<void> loadCompletedTasks() async {
    try {
      emit(BoardLoading());
      currentTab = BoardTabType.completed;
      final tasks = await getCompletedTasksUseCase();
      currentTasks = tasks;
      emit(BoardTasksLoaded(tasks, currentTab));
    } catch (e) {
      emit(BoardError(e.toString()));
    }
  }

  Future<void> loadUncompletedTasks() async {
    try {
      emit(BoardLoading());
      currentTab = BoardTabType.uncompleted;
      final tasks = await getUncompletedTasksUseCase();
      currentTasks = tasks;
      emit(BoardTasksLoaded(tasks, currentTab));
    } catch (e) {
      emit(BoardError(e.toString()));
    }
  }

  Future<void> loadFavoriteTasks() async {
    try {
      emit(BoardLoading());
      currentTab = BoardTabType.favorite;
      final tasks = await getFavoriteTasksUseCase();
      currentTasks = tasks;
      emit(BoardTasksLoaded(tasks, currentTab));
    } catch (e) {
      emit(BoardError(e.toString()));
    }
  }

  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      // Optimistic update
      final taskIndex = currentTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final updatedTask = currentTasks[taskIndex].copyWith(
          isCompleted: isCompleted,
        );
        currentTasks[taskIndex] = updatedTask;
        emit(BoardTasksLoaded(List.from(currentTasks), currentTab));
      }

      // Update in repository
      await updateTaskCompletionUseCase(taskId, isCompleted);

      // Reload to ensure consistency
      await loadTasks();
    } catch (e) {
      // Revert optimistic update on error
      await loadTasks();
      emit(BoardError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> toggleTaskFavorite(int taskId, bool isFavorite) async {
    try {
      // Optimistic update
      final taskIndex = currentTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final updatedTask = currentTasks[taskIndex].copyWith(
          isFavorite: isFavorite,
        );
        currentTasks[taskIndex] = updatedTask;
        emit(BoardTasksLoaded(List.from(currentTasks), currentTab));
      }

      // Update in repository
      await updateTaskFavoriteUseCase(taskId, isFavorite);

      // Reload to ensure consistency
      await loadTasks();
    } catch (e) {
      // Revert optimistic update on error
      await loadTasks();
      emit(BoardError('Failed to update task favorite: ${e.toString()}'));
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      emit(BoardLoading());

      await deleteTaskUseCase(taskId);

      // Reload current tab
      await loadTasks();

      emit(BoardTaskDeleted(taskId));
    } catch (e) {
      emit(BoardError('Failed to delete task: ${e.toString()}'));
    }
  }

  void setCurrentTab(BoardTabType tab) {
    currentTab = tab;
    emit(BoardTabChanged(tab));
  }

  // Helper methods
  Task? getTaskById(int id) {
    try {
      return currentTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  int get tasksCount => currentTasks.length;

  int get completedTasksCount =>
      currentTasks.where((task) => task.isCompleted).length;

  int get uncompletedTasksCount =>
      currentTasks.where((task) => !task.isCompleted).length;

  int get favoriteTasksCount =>
      currentTasks.where((task) => task.isFavorite).length;
}

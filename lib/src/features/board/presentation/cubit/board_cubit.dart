// presentation/cubit/board_cubit.dart (Fixed with comprehensive debugging)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_all_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_completed_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_uncompleted_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_favorite_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_completion_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_favorite_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/delete_task_use_case.dart';

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
  }) : super(BoardInitial()) {
    debugPrint('🏗️ BoardCubit: Constructor called');
  }

  static BoardCubit get(context) => BlocProvider.of<BoardCubit>(context);

  BoardTabType _currentTab = BoardTabType.all;
  List<Task> _allTasks = [];
  List<Task> _currentTasks = [];

  BoardTabType get currentTab => _currentTab;

  List<Task> get currentTasks => _currentTasks;

  Future<void> loadAllTasks() async {
    try {
      debugPrint('🔄 BoardCubit: Starting loadAllTasks');
      emit(BoardLoading());
      _currentTab = BoardTabType.all;

      debugPrint('🔄 BoardCubit: Calling getAllTasksUseCase...');
      final tasks = await getAllTasksUseCase();

      debugPrint(
        '✅ BoardCubit: getAllTasksUseCase returned ${tasks.length} tasks',
      );
      for (var task in tasks) {
        debugPrint(
          '📋 Task: ${task.id} - ${task.title} (completed: ${task.isCompleted}, favorite: ${task.isFavorite})',
        );
      }

      _allTasks = tasks;
      _currentTasks = tasks;

      debugPrint(
        '✅ BoardCubit: Emitting BoardTasksLoaded with ${tasks.length} tasks',
      );
      emit(BoardTasksLoaded(tasks, _currentTab));
    } catch (e, stackTrace) {
      debugPrint('❌ BoardCubit: Error loading all tasks: $e');
      debugPrint('❌ BoardCubit: Stack trace: $stackTrace');
      emit(BoardError('Failed to load tasks: $e'));
    }
  }

  Future<void> loadCompletedTasks() async {
    try {
      debugPrint('🔄 BoardCubit: Starting loadCompletedTasks');
      emit(BoardLoading());
      _currentTab = BoardTabType.completed;

      debugPrint('🔄 BoardCubit: Calling getCompletedTasksUseCase...');
      final tasks = await getCompletedTasksUseCase();

      debugPrint(
        '✅ BoardCubit: getCompletedTasksUseCase returned ${tasks.length} completed tasks',
      );
      _currentTasks = tasks;

      debugPrint(
        '✅ BoardCubit: Emitting BoardTasksLoaded with ${tasks.length} completed tasks',
      );
      emit(BoardTasksLoaded(tasks, _currentTab));
    } catch (e, stackTrace) {
      debugPrint('❌ BoardCubit: Error loading completed tasks: $e');
      debugPrint('❌ BoardCubit: Stack trace: $stackTrace');
      emit(BoardError('Failed to load completed tasks: $e'));
    }
  }

  Future<void> loadUncompletedTasks() async {
    try {
      debugPrint('🔄 BoardCubit: Starting loadUncompletedTasks');
      emit(BoardLoading());
      _currentTab = BoardTabType.uncompleted;

      debugPrint('🔄 BoardCubit: Calling getUncompletedTasksUseCase...');
      final tasks = await getUncompletedTasksUseCase();

      debugPrint(
        '✅ BoardCubit: getUncompletedTasksUseCase returned ${tasks.length} uncompleted tasks',
      );
      _currentTasks = tasks;

      debugPrint(
        '✅ BoardCubit: Emitting BoardTasksLoaded with ${tasks.length} uncompleted tasks',
      );
      emit(BoardTasksLoaded(tasks, _currentTab));
    } catch (e, stackTrace) {
      debugPrint('❌ BoardCubit: Error loading uncompleted tasks: $e');
      debugPrint('❌ BoardCubit: Stack trace: $stackTrace');
      emit(BoardError('Failed to load uncompleted tasks: $e'));
    }
  }

  Future<void> loadFavoriteTasks() async {
    try {
      debugPrint('🔄 BoardCubit: Starting loadFavoriteTasks');
      emit(BoardLoading());
      _currentTab = BoardTabType.favorite;

      debugPrint('🔄 BoardCubit: Calling getFavoriteTasksUseCase...');
      final tasks = await getFavoriteTasksUseCase();

      debugPrint(
        '✅ BoardCubit: getFavoriteTasksUseCase returned ${tasks.length} favorite tasks',
      );
      _currentTasks = tasks;

      debugPrint(
        '✅ BoardCubit: Emitting BoardTasksLoaded with ${tasks.length} favorite tasks',
      );
      emit(BoardTasksLoaded(tasks, _currentTab));
    } catch (e, stackTrace) {
      debugPrint('❌ BoardCubit: Error loading favorite tasks: $e');
      debugPrint('❌ BoardCubit: Stack trace: $stackTrace');
      emit(BoardError('Failed to load favorite tasks: $e'));
    }
  }

  void setCurrentTab(BoardTabType tab) {
    debugPrint(
      '📱 BoardCubit: setCurrentTab called with: $tab (current: $_currentTab)',
    );

    if (_currentTab != tab) {
      _currentTab = tab;
      emit(BoardTabChanged(tab));
      _loadTasksForCurrentTab();
    } else {
      debugPrint('📱 BoardCubit: Tab unchanged, not reloading');
    }
  }

  Future<void> _loadTasksForCurrentTab() async {
    debugPrint(
      '🔄 BoardCubit: _loadTasksForCurrentTab - loading for $_currentTab',
    );

    switch (_currentTab) {
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

  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      debugPrint(
        '🔄 BoardCubit: Toggling task $taskId completion to $isCompleted',
      );

      // Optimistic update
      _updateTaskInCurrentList(
        taskId,
        (task) => task.copyWith(isCompleted: isCompleted),
      );
      emit(BoardTasksLoaded(_currentTasks, _currentTab));

      // Update in repository
      await updateTaskCompletionUseCase(taskId, isCompleted);

      debugPrint('✅ BoardCubit: Task completion updated successfully');

      // Reload current tab to ensure consistency
      await _loadTasksForCurrentTab();
    } catch (e) {
      debugPrint('❌ BoardCubit: Error toggling task completion: $e');
      // Revert optimistic update on error
      await _loadTasksForCurrentTab();
      emit(BoardError('Failed to update task: $e'));
    }
  }

  Future<void> toggleTaskFavorite(int taskId, bool isFavorite) async {
    try {
      debugPrint(
        '🔄 BoardCubit: Toggling task $taskId favorite to $isFavorite',
      );

      // Optimistic update
      _updateTaskInCurrentList(
        taskId,
        (task) => task.copyWith(isFavorite: isFavorite),
      );
      emit(BoardTasksLoaded(_currentTasks, _currentTab));

      // Update in repository
      await updateTaskFavoriteUseCase(taskId, isFavorite);

      debugPrint('✅ BoardCubit: Task favorite updated successfully');

      // Reload current tab to ensure consistency
      await _loadTasksForCurrentTab();
    } catch (e) {
      debugPrint('❌ BoardCubit: Error toggling task favorite: $e');
      // Revert optimistic update on error
      await _loadTasksForCurrentTab();
      emit(BoardError('Failed to update task favorite: $e'));
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      debugPrint('🗑️ BoardCubit: Deleting task $taskId');
      emit(BoardLoading());

      await deleteTaskUseCase(taskId);

      // Remove from local lists
      _currentTasks.removeWhere((task) => task.id == taskId);
      _allTasks.removeWhere((task) => task.id == taskId);

      debugPrint('✅ BoardCubit: Task deleted successfully');

      emit(BoardTaskDeleted(taskId));
      emit(BoardTasksLoaded(_currentTasks, _currentTab));
    } catch (e) {
      debugPrint('❌ BoardCubit: Error deleting task: $e');
      emit(BoardError('Failed to delete task: $e'));
    }
  }

  Future<void> refreshTasks() async {
    debugPrint('🔄 BoardCubit: Refreshing tasks for current tab: $_currentTab');
    await _loadTasksForCurrentTab();
  }

  // Helper methods
  void _updateTaskInCurrentList(int taskId, Task Function(Task) update) {
    final index = _currentTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _currentTasks[index] = update(_currentTasks[index]);
    }
  }

  // Statistics
  int get totalTasks => _allTasks.length;

  int get completedTasks => _allTasks.where((task) => task.isCompleted).length;

  int get uncompletedTasks =>
      _allTasks.where((task) => !task.isCompleted).length;

  int get favoriteTasks => _allTasks.where((task) => task.isFavorite).length;

  int get currentTabTaskCount => _currentTasks.length;
}

// presentation/cubit/schedule_cubit.dart (Enhanced debugging and fixed data flow)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_completion_use_case.dart';
import 'package:todo_app/src/features/schedule/domain/entities/schedule_day.dart';
import 'package:todo_app/src/features/schedule/domain/use_cases/get_tasks_by_date_range_use_case.dart';
import 'package:todo_app/src/features/schedule/domain/use_cases/get_tasks_by_date_use_case.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetTasksByDateUseCase getTasksByDateUseCase;
  final GetTasksByDateRangeUseCase getTasksByDateRangeUseCase;
  final UpdateTaskCompletionUseCase updateTaskCompletionUseCase;

  ScheduleCubit({
    required this.getTasksByDateUseCase,
    required this.getTasksByDateRangeUseCase,
    required this.updateTaskCompletionUseCase,
  }) : super(ScheduleInitial()) {
    debugPrint('🏗️ ScheduleCubit: Constructor called');
  }

  static ScheduleCubit get(context) => BlocProvider.of<ScheduleCubit>(context);

  DateTime _selectedDate = DateTime.now();
  List<Task> _currentTasks = [];
  Map<String, List<Task>> _weekTasks = {};

  DateTime get selectedDate => _selectedDate;

  List<Task> get currentTasks => _currentTasks;

  String get formattedSelectedDate {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = _selectedDate.weekday == 7 ? 0 : _selectedDate.weekday;
    return '${days[weekday]}, ${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Future<void> loadTasksForDate(DateTime date) async {
    try {
      debugPrint(
        '🔄 ScheduleCubit: Starting loadTasksForDate for ${date.toString()}',
      );
      emit(ScheduleLoading());
      _selectedDate = date;

      final dateString = _formatDateString(date);
      debugPrint('📅 ScheduleCubit: Formatted date string: $dateString');

      // Call the use case
      debugPrint('🔄 ScheduleCubit: Calling getTasksByDateUseCase...');
      final tasks = await getTasksByDateUseCase(dateString);

      debugPrint('✅ ScheduleCubit: Use case returned ${tasks.length} tasks');
      for (var task in tasks) {
        debugPrint('📋 Task: ${task.id} - ${task.title} (${task.date})');
      }

      _currentTasks = tasks;

      final scheduleDay = ScheduleDay.fromTasks(date, tasks);
      debugPrint(
        '📊 ScheduleCubit: Created ScheduleDay with ${scheduleDay.totalCount} tasks',
      );

      emit(ScheduleTasksLoaded(scheduleDay, _selectedDate));
      debugPrint('✅ ScheduleCubit: Emitted ScheduleTasksLoaded state');
    } catch (e, stackTrace) {
      debugPrint('❌ ScheduleCubit: Error in loadTasksForDate: $e');
      debugPrint('❌ ScheduleCubit: Stack trace: $stackTrace');
      emit(ScheduleError('Failed to load tasks: $e'));
    }
  }

  Future<void> loadTasksForWeek(DateTime startOfWeek) async {
    try {
      debugPrint(
        '🔄 ScheduleCubit: Loading tasks for week starting: $startOfWeek',
      );
      emit(ScheduleLoading());

      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final tasksByDate = await getTasksByDateRangeUseCase(
        startOfWeek,
        endOfWeek,
      );

      _weekTasks = tasksByDate;

      debugPrint(
        '✅ ScheduleCubit: Loaded week tasks for ${tasksByDate.length} days',
      );

      emit(ScheduleWeekLoaded(tasksByDate, startOfWeek));
    } catch (e) {
      debugPrint('❌ ScheduleCubit: Error loading week tasks: $e');
      emit(ScheduleError('Failed to load week tasks: $e'));
    }
  }

  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      debugPrint(
        '🔄 ScheduleCubit: Toggling task $taskId completion to $isCompleted',
      );

      // Optimistic update
      _updateTaskInCurrentList(
        taskId,
        (task) => task.copyWith(isCompleted: isCompleted),
      );
      emit(
        ScheduleTasksLoaded(
          ScheduleDay.fromTasks(_selectedDate, _currentTasks),
          _selectedDate,
        ),
      );

      // Update in repository
      await updateTaskCompletionUseCase(taskId, isCompleted);

      debugPrint('✅ ScheduleCubit: Task completion updated successfully');

      // Reload to ensure consistency
      await loadTasksForDate(_selectedDate);
    } catch (e) {
      debugPrint('❌ ScheduleCubit: Error toggling task completion: $e');
      // Revert optimistic update on error
      await loadTasksForDate(_selectedDate);
      emit(ScheduleError('Failed to update task: $e'));
    }
  }

  void setSelectedDate(DateTime date) {
    debugPrint('📅 ScheduleCubit: setSelectedDate called with: $date');
    if (_selectedDate != date) {
      _selectedDate = date;
      emit(ScheduleDateChanged(date));
      loadTasksForDate(date);
    } else {
      debugPrint('📅 ScheduleCubit: Date unchanged, not reloading');
    }
  }

  Future<void> refreshCurrentDate() async {
    debugPrint(
      '🔄 ScheduleCubit: Refreshing tasks for current date: $_selectedDate',
    );
    await loadTasksForDate(_selectedDate);
  }

  // Helper methods
  void _updateTaskInCurrentList(int taskId, Task Function(Task) update) {
    final index = _currentTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _currentTasks[index] = update(_currentTasks[index]);
    }
  }

  String _formatDateString(DateTime date) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    debugPrint('📅 ScheduleCubit: _formatDateString: $date -> $formatted');
    return formatted;
  }

  // Statistics
  int get totalTasksForDay => _currentTasks.length;

  int get completedTasksForDay =>
      _currentTasks.where((task) => task.isCompleted).length;

  int get pendingTasksForDay => totalTasksForDay - completedTasksForDay;

  double get completionPercentage =>
      totalTasksForDay > 0 ? completedTasksForDay / totalTasksForDay : 0.0;

  bool get hasTasksForDay => _currentTasks.isNotEmpty;

  bool get hasCompletedAllTasks =>
      totalTasksForDay > 0 && completedTasksForDay == totalTasksForDay;
}

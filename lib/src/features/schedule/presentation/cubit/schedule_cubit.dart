// Enhanced schedule_cubit.dart - Fixed database integration with detailed debugging
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

    // Load today's tasks immediately when cubit is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTasksForDate(DateTime.now());
    });
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selected == today) {
      return 'Today, ${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    }

    return '${days[weekday]}, ${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Future<void> loadTasksForDate(DateTime date) async {
    try {
      debugPrint(
        '🔄 ScheduleCubit: Starting loadTasksForDate for ${date.toString()}',
      );
      debugPrint('🔄 ScheduleCubit: Current state: ${state.runtimeType}');

      emit(ScheduleLoading());
      _selectedDate = date;

      final dateString = _formatDateString(date);
      debugPrint('📅 ScheduleCubit: Formatted date string: $dateString');

      // Verify use case is available
      debugPrint('🔄 ScheduleCubit: Verifying use case availability...');
      if (getTasksByDateUseCase == null) {
        throw Exception('GetTasksByDateUseCase is null');
      }

      // Call the use case with detailed logging
      debugPrint(
        '🔄 ScheduleCubit: Calling getTasksByDateUseCase with date: $dateString',
      );
      final tasks = await getTasksByDateUseCase(dateString);

      debugPrint('✅ ScheduleCubit: Use case returned ${tasks.length} tasks');

      // Log each task for debugging
      if (tasks.isNotEmpty) {
        debugPrint('📋 ScheduleCubit: Task details:');
        for (var i = 0; i < tasks.length; i++) {
          final task = tasks[i];
          debugPrint(
            '   Task $i: ID=${task.id}, Title="${task.title}", Date="${task.date}", Time="${task.startTime}-${task.endTime}", Completed=${task.isCompleted}',
          );
        }
      } else {
        debugPrint('📭 ScheduleCubit: No tasks found for date $dateString');
      }

      _currentTasks = tasks;

      final scheduleDay = ScheduleDay.fromTasks(date, tasks);
      debugPrint('📊 ScheduleCubit: Created ScheduleDay:');
      debugPrint('   - Date: ${scheduleDay.date}');
      debugPrint('   - Total tasks: ${scheduleDay.totalCount}');
      debugPrint('   - Completed tasks: ${scheduleDay.completedCount}');
      debugPrint(
        '   - Completion percentage: ${(scheduleDay.completionPercentage * 100).toStringAsFixed(1)}%',
      );

      debugPrint('✅ ScheduleCubit: Emitting ScheduleTasksLoaded state');
      emit(ScheduleTasksLoaded(scheduleDay, _selectedDate));

      debugPrint('🎉 ScheduleCubit: loadTasksForDate completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ ScheduleCubit: Error in loadTasksForDate: $e');
      debugPrint('❌ ScheduleCubit: Stack trace: $stackTrace');

      // Provide more specific error information
      String errorMessage = 'Failed to load tasks';
      if (e.toString().contains('no such table')) {
        errorMessage = 'Database table not found. Please restart the app.';
      } else if (e.toString().contains('database is locked')) {
        errorMessage = 'Database is busy. Please try again.';
      } else if (e.toString().contains('Invalid date format')) {
        errorMessage = 'Invalid date format. Please select a valid date.';
      }

      emit(ScheduleError('$errorMessage: $e'));
    }
  }

  Future<void> loadTasksForWeek(DateTime startOfWeek) async {
    try {
      debugPrint(
        '🔄 ScheduleCubit: Loading tasks for week starting: $startOfWeek',
      );
      emit(ScheduleLoading());

      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      debugPrint('🔄 ScheduleCubit: Week range: $startOfWeek to $endOfWeek');

      final tasksByDate = await getTasksByDateRangeUseCase(
        startOfWeek,
        endOfWeek,
      );

      _weekTasks = tasksByDate;

      debugPrint(
        '✅ ScheduleCubit: Loaded week tasks for ${tasksByDate.length} days',
      );

      // Log week summary
      int totalWeekTasks = 0;
      tasksByDate.forEach((date, tasks) {
        totalWeekTasks += tasks.length;
        debugPrint('   $date: ${tasks.length} tasks');
      });
      debugPrint('📊 ScheduleCubit: Total tasks for week: $totalWeekTasks');

      emit(ScheduleWeekLoaded(tasksByDate, startOfWeek));
    } catch (e, stackTrace) {
      debugPrint('❌ ScheduleCubit: Error loading week tasks: $e');
      debugPrint('❌ ScheduleCubit: Stack trace: $stackTrace');
      emit(ScheduleError('Failed to load week tasks: $e'));
    }
  }

  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      debugPrint(
        '🔄 ScheduleCubit: Toggling task $taskId completion to $isCompleted',
      );

      // Find the task in current list
      final taskIndex = _currentTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        debugPrint('⚠️ ScheduleCubit: Task $taskId not found in current tasks');
        return;
      }

      // Optimistic update
      final originalTask = _currentTasks[taskIndex];
      _currentTasks[taskIndex] = originalTask.copyWith(
        isCompleted: isCompleted,
      );

      // Emit updated state immediately for better UX
      final updatedScheduleDay = ScheduleDay.fromTasks(
        _selectedDate,
        _currentTasks,
      );
      emit(ScheduleTasksLoaded(updatedScheduleDay, _selectedDate));

      debugPrint('✅ ScheduleCubit: Optimistic update applied');

      // Update in repository
      await updateTaskCompletionUseCase(taskId, isCompleted);

      debugPrint('✅ ScheduleCubit: Task completion updated in database');

      // Reload to ensure consistency
      await loadTasksForDate(_selectedDate);
    } catch (e, stackTrace) {
      debugPrint('❌ ScheduleCubit: Error toggling task completion: $e');
      debugPrint('❌ ScheduleCubit: Stack trace: $stackTrace');

      // Revert optimistic update on error
      await loadTasksForDate(_selectedDate);
      emit(ScheduleError('Failed to update task: $e'));
    }
  }

  void setSelectedDate(DateTime date) {
    debugPrint('📅 ScheduleCubit: setSelectedDate called with: $date');
    debugPrint('📅 ScheduleCubit: Current selected date: $_selectedDate');

    final newDateOnly = DateTime(date.year, date.month, date.day);
    final currentDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (newDateOnly != currentDateOnly) {
      debugPrint('📅 ScheduleCubit: Date changed, loading new tasks');
      _selectedDate = newDateOnly;
      emit(ScheduleDateChanged(newDateOnly));
      loadTasksForDate(newDateOnly);
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

  // Enhanced debugging for date formatting
  String _formatDateString(DateTime date) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    debugPrint('📅 ScheduleCubit: _formatDateString: $date -> $formatted');

    // Additional validation
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(formatted)) {
      debugPrint('⚠️ ScheduleCubit: Invalid date format: $formatted');
    }

    return formatted;
  }

  // Enhanced statistics with debugging
  int get totalTasksForDay {
    final count = _currentTasks.length;
    debugPrint('📊 ScheduleCubit: totalTasksForDay = $count');
    return count;
  }

  int get completedTasksForDay {
    final count = _currentTasks.where((task) => task.isCompleted).length;
    debugPrint('📊 ScheduleCubit: completedTasksForDay = $count');
    return count;
  }

  int get pendingTasksForDay {
    final count = totalTasksForDay - completedTasksForDay;
    debugPrint('📊 ScheduleCubit: pendingTasksForDay = $count');
    return count;
  }

  double get completionPercentage {
    final percentage = totalTasksForDay > 0
        ? completedTasksForDay / totalTasksForDay
        : 0.0;
    debugPrint(
      '📊 ScheduleCubit: completionPercentage = ${(percentage * 100).toStringAsFixed(1)}%',
    );
    return percentage;
  }

  bool get hasTasksForDay {
    final hasData = _currentTasks.isNotEmpty;
    debugPrint('📊 ScheduleCubit: hasTasksForDay = $hasData');
    return hasData;
  }

  bool get hasCompletedAllTasks {
    final completed =
        totalTasksForDay > 0 && completedTasksForDay == totalTasksForDay;
    debugPrint('📊 ScheduleCubit: hasCompletedAllTasks = $completed');
    return completed;
  }

  // Diagnostic method for debugging
  void debugCurrentState() {
    debugPrint('🔍 ScheduleCubit: === CURRENT STATE DEBUG ===');
    debugPrint('🔍 Selected Date: $_selectedDate');
    debugPrint('🔍 Current Tasks Count: ${_currentTasks.length}');
    debugPrint('🔍 State Type: ${state.runtimeType}');

    if (state is ScheduleTasksLoaded) {
      final loadedState = state as ScheduleTasksLoaded;
      debugPrint(
        '🔍 Loaded State Tasks: ${loadedState.scheduleDay.tasks.length}',
      );
      debugPrint('🔍 Loaded State Date: ${loadedState.scheduleDay.date}');
    }

    debugPrint('🔍 === END STATE DEBUG ===');
  }
}

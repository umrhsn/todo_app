// presentation/cubit/schedule_cubit.dart
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
  }) : super(ScheduleInitial());

  static ScheduleCubit get(context) => BlocProvider.of<ScheduleCubit>(context);

  DateTime selectedDate = DateTime.now();
  List<Task> currentTasks = [];
  Map<String, List<Task>> weekTasks = {};

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

    return '${days[selectedDate.weekday % 7]}, ${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  Future<void> loadTasksForDate(DateTime date) async {
    try {
      emit(ScheduleLoading());
      selectedDate = date;

      final dateString = _formatDateString(date);
      final tasks = await getTasksByDateUseCase(dateString);

      currentTasks = tasks;

      emit(
        ScheduleTasksLoaded(ScheduleDay.fromTasks(date, tasks), selectedDate),
      );
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> loadTasksForWeek(DateTime startOfWeek) async {
    try {
      emit(ScheduleLoading());

      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final tasksByDate = await getTasksByDateRangeUseCase(
        startOfWeek,
        endOfWeek,
      );

      weekTasks = tasksByDate;

      emit(ScheduleWeekLoaded(tasksByDate, startOfWeek));
    } catch (e) {
      emit(ScheduleError(e.toString()));
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

        emit(
          ScheduleTasksLoaded(
            ScheduleDay.fromTasks(selectedDate, currentTasks),
            selectedDate,
          ),
        );
      }

      // Update in repository
      await updateTaskCompletionUseCase(taskId, isCompleted);

      // Reload to ensure consistency
      await loadTasksForDate(selectedDate);
    } catch (e) {
      // Revert optimistic update on error
      await loadTasksForDate(selectedDate);
      emit(ScheduleError('Failed to update task: ${e.toString()}'));
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    emit(ScheduleDateChanged(date));
  }

  Future<void> refreshCurrentDate() async {
    await loadTasksForDate(selectedDate);
  }

  // Helper methods
  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Task? getTaskById(int id) {
    try {
      return currentTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    final dateString = _formatDateString(date);
    return weekTasks[dateString] ?? [];
  }

  // Statistics
  int get totalTasksForDay => currentTasks.length;

  int get completedTasksForDay =>
      currentTasks.where((task) => task.isCompleted).length;

  int get pendingTasksForDay => totalTasksForDay - completedTasksForDay;

  double get completionPercentage =>
      totalTasksForDay > 0 ? completedTasksForDay / totalTasksForDay : 0.0;

  bool get hasTasksForDay => currentTasks.isNotEmpty;

  bool get hasCompletedAllTasks =>
      totalTasksForDay > 0 && completedTasksForDay == totalTasksForDay;
}

// domain/entities/schedule_day.dart
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';

class ScheduleDay extends Equatable {
  final DateTime date;
  final List<Task> tasks;
  final int completedCount;
  final int totalCount;

  const ScheduleDay({
    required this.date,
    required this.tasks,
    required this.completedCount,
    required this.totalCount,
  });

  factory ScheduleDay.fromTasks(DateTime date, List<Task> tasks) {
    final completedCount = tasks.where((task) => task.isCompleted).length;
    return ScheduleDay(
      date: date,
      tasks: tasks,
      completedCount: completedCount,
      totalCount: tasks.length,
    );
  }

  bool get hasCompletedAll => totalCount > 0 && completedCount == totalCount;

  bool get hasNoTasks => totalCount == 0;

  double get completionPercentage =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  @override
  List<Object?> get props => [date, tasks, completedCount, totalCount];
}

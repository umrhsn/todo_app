// domain/use_cases/get_tasks_by_date_range_use_case.dart

import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class GetTasksByDateRangeUseCase {
  final TaskRepository repository;

  GetTasksByDateRangeUseCase({required this.repository});

  Future<Map<String, List<Task>>> call(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (endDate.isBefore(startDate)) {
      throw Exception('End date cannot be before start date');
    }

    final Map<String, List<Task>> tasksByDate = {};

    // Get tasks for each day in the range
    for (
      DateTime date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final tasks = await repository.getTasksByDate(dateString);
      tasksByDate[dateString] = tasks;
    }

    return tasksByDate;
  }
}

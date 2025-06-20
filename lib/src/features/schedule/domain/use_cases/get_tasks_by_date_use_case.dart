// domain/use_cases/get_tasks_by_date_use_case.dart
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class GetTasksByDateUseCase {
  final TaskRepository repository;

  GetTasksByDateUseCase({required this.repository});

  Future<List<Task>> call(String date) async {
    if (date.isEmpty) {
      throw Exception('Date cannot be empty');
    }

    // Validate date format (YYYY-MM-DD)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      throw Exception('Invalid date format. Expected: YYYY-MM-DD');
    }

    return await repository.getTasksByDate(date);
  }
}

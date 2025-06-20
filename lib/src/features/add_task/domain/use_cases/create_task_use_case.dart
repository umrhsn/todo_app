import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase({required this.repository});

  Future<int> call(Task task) async {
    // Validation logic
    if (task.title.trim().isEmpty) {
      throw Exception('Task title cannot be empty');
    }

    if (task.title.trim().length < 3) {
      throw Exception('Task title must be at least 3 characters long');
    }

    // Additional validation
    if (task.date.isEmpty) {
      throw Exception('Task date is required');
    }

    return await repository.createTask(task);
  }
}

// domain/use_cases/update_task_completion_use_case.dart

import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class UpdateTaskCompletionUseCase {
  final TaskRepository repository;

  UpdateTaskCompletionUseCase({required this.repository});

  Future<void> call(int id, bool isCompleted) async {
    if (id <= 0) {
      throw Exception('Invalid task ID');
    }
    return await repository.updateTaskCompletion(id, isCompleted);
  }
}

// domain/use_cases/delete_task_use_case.dart
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase({required this.repository});

  Future<void> call(int id) async {
    if (id <= 0) {
      throw Exception('Invalid task ID');
    }
    return await repository.deleteTask(id);
  }
}

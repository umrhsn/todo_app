// domain/use_cases/get_all_tasks_use_case.dart

import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class GetAllTasksUseCase {
  final TaskRepository repository;

  GetAllTasksUseCase({required this.repository});

  Future<List<Task>> call() async {
    return await repository.getAllTasks();
  }
}

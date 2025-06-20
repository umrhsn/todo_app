// domain/use_cases/get_uncompleted_tasks_use_case.dart

import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class GetUncompletedTasksUseCase {
  final TaskRepository repository;

  GetUncompletedTasksUseCase({required this.repository});

  Future<List<Task>> call() async {
    return await repository.getUncompletedTasks();
  }
}

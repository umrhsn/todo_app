// domain/use_cases/update_task_favorite_use_case.dart

import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class UpdateTaskFavoriteUseCase {
  final TaskRepository repository;

  UpdateTaskFavoriteUseCase({required this.repository});

  Future<void> call(int id, bool isFavorite) async {
    if (id <= 0) {
      throw Exception('Invalid task ID');
    }
    return await repository.updateTaskFavorite(id, isFavorite);
  }
}

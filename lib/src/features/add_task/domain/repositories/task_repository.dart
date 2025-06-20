// domain/repositories/task_repository.dart

import 'package:todo_app/src/features/add_task/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getUncompletedTasks();
  Future<List<Task>> getFavoriteTasks();
  Future<List<Task>> getTasksByDate(String date);
  Future<int> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> updateTaskCompletion(int id, bool isCompleted);
  Future<void> updateTaskFavorite(int id, bool isFavorite);
  Future<void> deleteTask(int id);
}
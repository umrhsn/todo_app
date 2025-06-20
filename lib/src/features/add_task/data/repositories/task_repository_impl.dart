// data/repositories/task_repository_impl.dart

import 'package:todo_app/src/features/add_task/data/data_sources/task_local_data_source.dart';
import 'package:todo_app/src/features/add_task/data/models/task_model.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDatasource;

  TaskRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Task>> getAllTasks() async {
    final taskModels = await localDatasource.getAllTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final taskModels = await localDatasource.getCompletedTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getUncompletedTasks() async {
    final taskModels = await localDatasource.getUncompletedTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getFavoriteTasks() async {
    final taskModels = await localDatasource.getFavoriteTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByDate(String date) async {
    final taskModels = await localDatasource.getTasksByDate(date);
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> createTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    return await localDatasource.createTask(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDatasource.updateTask(taskModel);
  }

  @override
  Future<void> updateTaskCompletion(int id, bool isCompleted) async {
    await localDatasource.updateTaskCompletion(id, isCompleted);
  }

  @override
  Future<void> updateTaskFavorite(int id, bool isFavorite) async {
    await localDatasource.updateTaskFavorite(id, isFavorite);
  }

  @override
  Future<void> deleteTask(int id) async {
    await localDatasource.deleteTask(id);
  }
}

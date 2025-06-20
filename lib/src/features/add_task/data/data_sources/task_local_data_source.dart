// data/datasources/task_local_datasource.dart
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/src/features/add_task/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<List<TaskModel>> getCompletedTasks();
  Future<List<TaskModel>> getUncompletedTasks();
  Future<List<TaskModel>> getFavoriteTasks();
  Future<List<TaskModel>> getTasksByDate(String date);
  Future<int> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> updateTaskCompletion(int id, bool isCompleted);
  Future<void> updateTaskFavorite(int id, bool isFavorite);
  Future<void> deleteTask(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Database database;

  TaskLocalDataSourceImpl({required this.database});

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final maps = await database.query(
        'tasks',
        orderBy: 'date DESC, startTime ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get all tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      final maps = await database.query(
        'tasks',
        where: 'isCompleted = ?',
        whereArgs: [1],
        orderBy: 'date DESC, startTime ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get completed tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getUncompletedTasks() async {
    try {
      final maps = await database.query(
        'tasks',
        where: 'isCompleted = ?',
        whereArgs: [0],
        orderBy: 'date DESC, startTime ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get uncompleted tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getFavoriteTasks() async {
    try {
      final maps = await database.query(
        'tasks',
        where: 'isFavorite = ?',
        whereArgs: [1],
        orderBy: 'date DESC, startTime ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get favorite tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByDate(String date) async {
    try {
      final maps = await database.query(
        'tasks',
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'startTime ASC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get tasks by date: $e');
    }
  }

  @override
  Future<int> createTask(TaskModel task) async {
    try {
      final taskMap = task.toMap();
      taskMap.remove('id'); // Remove id for auto-increment
      return await database.insert('tasks', taskMap);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await database.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> updateTaskCompletion(int id, bool isCompleted) async {
    try {
      await database.update(
        'tasks',
        {'isCompleted': isCompleted ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update task completion: $e');
    }
  }

  @override
  Future<void> updateTaskFavorite(int id, bool isFavorite) async {
    try {
      await database.update(
        'tasks',
        {'isFavorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update task favorite: $e');
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await database.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
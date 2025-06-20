// db_cubit.dart (Updated to use clean architecture but maintain compatibility)
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/create_task_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/delete_task_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_all_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_completion_use_case.dart';
import 'injection_container.dart' as di;

part 'db_state.dart';

class DatabaseCubit extends Cubit<DatabaseState> {
  DatabaseCubit() : super(DatabaseInitial());

  static DatabaseCubit get(context) => BlocProvider.of<DatabaseCubit>(context);

  // Use cases (injected via dependency injection)
  late final GetAllTasksUseCase _getAllTasksUseCase;
  late final CreateTaskUseCase _createTaskUseCase;
  late final UpdateTaskCompletionUseCase _updateTaskCompletionUseCase;
  late final DeleteTaskUseCase _deleteTaskUseCase;
  late final TaskRepository _taskRepository;

  // Legacy compatibility
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  Map selectedTask = {};

  // Controllers for form inputs (maintained for UI compatibility)
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController remindController = TextEditingController();
  final TextEditingController repeatController = TextEditingController();

  @override
  Future<void> close() {
    // Dispose controllers to prevent memory leaks
    titleController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    remindController.dispose();
    repeatController.dispose();
    return super.close();
  }

  Future<void> initAppDatabase() async {
    try {
      emit(DatabaseLoading());

      // Wait for database to be ready
      await di.sl.allReady();

      // Initialize use cases
      _getAllTasksUseCase = di.sl<GetAllTasksUseCase>();
      _createTaskUseCase = di.sl<CreateTaskUseCase>();
      _updateTaskCompletionUseCase = di.sl<UpdateTaskCompletionUseCase>();
      _deleteTaskUseCase = di.sl<DeleteTaskUseCase>();
      _taskRepository = di.sl<TaskRepository>();

      debugPrint('Database initialized successfully');
      emit(DatabaseInitialized());

      // Load initial tasks
      await getAllTasks();
    } catch (e) {
      debugPrint('Database initialization failed: $e');
      emit(DatabaseError('Failed to initialize database: $e'));
    }
  }

  Future<void> getAllTasks() async {
    try {
      emit(DatabaseLoading());
      final taskList = await _getAllTasksUseCase();

      tasks = taskList;
      filteredTasks = List.from(tasks);

      debugPrint('All tasks fetched: ${tasks.length} tasks');
      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to get all tasks: $e');
      emit(DatabaseError('Failed to get tasks: $e'));
    }
  }

  Future<void> getCompletedTasks() async {
    try {
      emit(DatabaseLoading());
      final taskList = await _taskRepository.getCompletedTasks();

      filteredTasks = taskList;

      debugPrint('Completed tasks fetched: ${filteredTasks.length} tasks');
      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to get completed tasks: $e');
      emit(DatabaseError('Failed to get completed tasks: $e'));
    }
  }

  Future<void> getUnCompletedTasks() async {
    try {
      emit(DatabaseLoading());
      final taskList = await _taskRepository.getUncompletedTasks();

      filteredTasks = taskList;

      debugPrint('Uncompleted tasks fetched: ${filteredTasks.length} tasks');
      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to get uncompleted tasks: $e');
      emit(DatabaseError('Failed to get uncompleted tasks: $e'));
    }
  }

  Future<void> getFavoriteTasks() async {
    try {
      emit(DatabaseLoading());
      final taskList = await _taskRepository.getFavoriteTasks();

      filteredTasks = taskList;

      debugPrint('Favorite tasks fetched: ${filteredTasks.length} tasks');
      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to get favorite tasks: $e');
      emit(DatabaseError('Failed to get favorite tasks: $e'));
    }
  }

  Future<void> getTasksByDate(String date) async {
    try {
      emit(DatabaseLoading());
      final taskList = await _taskRepository.getTasksByDate(date);

      filteredTasks = taskList;

      debugPrint('Tasks for date $date fetched: ${filteredTasks.length} tasks');
      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to get tasks by date: $e');
      emit(DatabaseError('Failed to get tasks by date: $e'));
    }
  }

  Future<void> createTask({int? selectedColor}) async {
    try {
      if (titleController.text.trim().isEmpty) {
        emit(DatabaseError('Task title cannot be empty'));
        return;
      }

      emit(DatabaseLoading());

      // Create Task entity from form data
      final task = Task(
        id: 0,
        // Will be auto-generated
        title: titleController.text.trim(),
        date: dateController.text.isNotEmpty
            ? dateController.text
            : DateTime.now().toString().substring(0, 10),
        startTime: startTimeController.text.isNotEmpty
            ? startTimeController.text
            : '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        endTime: endTimeController.text.isNotEmpty
            ? endTimeController.text
            : '${(DateTime.now().hour + 1).toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        reminder: remindController.text.isNotEmpty
            ? remindController.text
            : '10 min before',
        repeatInterval: repeatController.text.isNotEmpty
            ? repeatController.text
            : 'None',
        colorIndex: selectedColor ?? 0,
        isCompleted: false,
        isFavorite: false,
        createdAt: DateTime.now(),
      );

      final id = await _createTaskUseCase(task);
      final createdTask = task.copyWith(id: id);

      // Clear form controllers
      _clearControllers();

      debugPrint('Task created with ID: $id');

      // Refresh current view
      await getAllTasks();

      emit(DatabaseTaskCreated(createdTask));
    } catch (e) {
      debugPrint('Failed to create task: $e');
      emit(DatabaseError('Failed to create task: $e'));
    }
  }

  Future<void> updateTaskCompletionState({
    required int id,
    required bool isCompleted,
  }) async {
    try {
      await _updateTaskCompletionUseCase(id, isCompleted);

      // Update local task lists immediately for better UX
      final taskIndex = tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        tasks[taskIndex] = tasks[taskIndex].copyWith(isCompleted: isCompleted);
      }

      final filteredTaskIndex = filteredTasks.indexWhere(
        (task) => task.id == id,
      );
      if (filteredTaskIndex != -1) {
        filteredTasks[filteredTaskIndex] = filteredTasks[filteredTaskIndex]
            .copyWith(isCompleted: isCompleted);
      }

      debugPrint('Task $id completion state updated to: $isCompleted');

      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to update task completion: $e');
      emit(DatabaseError('Failed to update task: $e'));
    }
  }

  Future<void> updateTaskFavoriteState({
    required int id,
    required bool isFavorite,
  }) async {
    try {
      emit(DatabaseLoading());

      await _taskRepository.updateTaskFavorite(id, isFavorite);

      // Update local task list
      final taskIndex = tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        tasks[taskIndex] = tasks[taskIndex].copyWith(isFavorite: isFavorite);
      }

      debugPrint('Task $id favorite state updated to: $isFavorite');

      // Refresh current view
      await getAllTasks();
    } catch (e) {
      debugPrint('Failed to update task favorite: $e');
      emit(DatabaseError('Failed to update task: $e'));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      emit(DatabaseLoading());

      await _deleteTaskUseCase(id);

      // Remove from local lists
      tasks.removeWhere((task) => task.id == id);
      filteredTasks.removeWhere((task) => task.id == id);

      debugPrint('Task $id deleted');

      emit(DatabaseTaskDeleted(id));
      emit(DatabaseTasksLoaded(filteredTasks));
    } catch (e) {
      debugPrint('Failed to delete task: $e');
      emit(DatabaseError('Failed to delete task: $e'));
    }
  }

  void _clearControllers() {
    titleController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    remindController.clear();
    repeatController.clear();
  }

  // Helper method to get task by ID
  Task? getTaskById(int id) {
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get tasks count
  int get tasksCount => filteredTasks.length;

  int get completedTasksCount => tasks.where((task) => task.isCompleted).length;

  int get uncompletedTasksCount =>
      tasks.where((task) => !task.isCompleted).length;

  int get favoriteTasksCount => tasks.where((task) => task.isFavorite).length;

  // Legacy compatibility methods
  void markTaskAsFavorite() {
    // This method was empty in original, keeping for compatibility
  }
}

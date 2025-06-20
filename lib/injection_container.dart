import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as join;
import 'package:todo_app/src/features/add_task/data/data_sources/task_local_data_source.dart';
import 'package:todo_app/src/features/add_task/data/repositories/task_repository_impl.dart';
import 'package:todo_app/src/features/add_task/domain/repositories/task_repository.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_all_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_completed_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_uncompleted_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/get_favorite_tasks_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/create_task_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_completion_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/update_task_favorite_use_case.dart';
import 'package:todo_app/src/features/add_task/domain/use_cases/delete_task_use_case.dart';
import 'package:todo_app/src/features/schedule/domain/use_cases/get_tasks_by_date_range_use_case.dart';
import 'package:todo_app/src/features/schedule/domain/use_cases/get_tasks_by_date_use_case.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/schedule/presentation/cubit/schedule_cubit.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // ========== Core - Initialize Database First ==========

  // Database - Register as regular singleton, not async
  final database = await _initDatabase();
  sl.registerLazySingleton<Database>(() => database);

  // ========== Data Layer ==========

  // Datasources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(database: sl()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDatasource: sl()),
  );

  // ========== Domain Layer - Use Cases ==========

  // Use cases
  sl.registerLazySingleton(() => GetAllTasksUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCompletedTasksUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUncompletedTasksUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetFavoriteTasksUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTasksByDateUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTasksByDateRangeUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateTaskCompletionUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateTaskFavoriteUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(repository: sl()));

  // ========== Presentation Layer - Cubits ==========

  // Board Cubit
  sl.registerFactory(
    () => BoardCubit(
      getAllTasksUseCase: sl(),
      getCompletedTasksUseCase: sl(),
      getUncompletedTasksUseCase: sl(),
      getFavoriteTasksUseCase: sl(),
      updateTaskCompletionUseCase: sl(),
      updateTaskFavoriteUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );

  // Schedule Cubit
  sl.registerFactory(
    () => ScheduleCubit(
      getTasksByDateUseCase: sl(),
      getTasksByDateRangeUseCase: sl(),
      updateTaskCompletionUseCase: sl(),
    ),
  );
}

Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join.join(dbPath, 'todo.db');

  return await openDatabase(
    path,
    version: 2,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          reminder TEXT NOT NULL,
          repeatInterval TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 0,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          isFavorite INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create indexes for better performance
      await db.execute('CREATE INDEX idx_tasks_date ON tasks(date)');
      await db.execute(
        'CREATE INDEX idx_tasks_completed ON tasks(isCompleted)',
      );
      await db.execute('CREATE INDEX idx_tasks_favorite ON tasks(isFavorite)');

      print('Database created successfully with indexes');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Add missing columns if upgrading from old schema
        try {
          await db.execute(
            'ALTER TABLE tasks ADD COLUMN color INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE tasks ADD COLUMN createdAt TEXT DEFAULT CURRENT_TIMESTAMP',
          );
          // Create indexes
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(isCompleted)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tasks_favorite ON tasks(isFavorite)',
          );
          print('Database upgraded successfully');
        } catch (e) {
          print('Upgrade error (columns might already exist): $e');
        }
      }
    },
  );
}

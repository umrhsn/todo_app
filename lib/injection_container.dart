// Fixed injection_container.dart - Added missing AddTaskCubit
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
import 'package:todo_app/src/features/add_task/presentation/cubit/add_task_cubit.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/schedule/presentation/cubit/schedule_cubit.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  print('🔧 DI: Starting dependency injection initialization...');

  // ========== Core - Initialize Database First ==========
  print('🔧 DI: Initializing database...');
  final database = await _initDatabase();
  sl.registerLazySingleton<Database>(() => database);
  print('✅ DI: Database registered successfully');

  // ========== Data Layer ==========
  print('🔧 DI: Registering data layer...');

  // Datasources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(database: sl()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDatasource: sl()),
  );
  print('✅ DI: Data layer registered successfully');

  // ========== Domain Layer - Use Cases ==========
  print('🔧 DI: Registering use cases...');

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
  print('✅ DI: Use cases registered successfully');

  // ========== Presentation Layer - Cubits ==========
  print('🔧 DI: Registering cubits...');

  // AddTask Cubit - Fixed registration
  sl.registerFactory(
    () => AddTaskCubit(
      getAllTasksUseCase: sl(),
      createTaskUseCase: sl(),
      updateTaskCompletionUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );

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

  print('✅ DI: All cubits registered successfully');
  print('🎉 DI: Dependency injection initialization completed!');
}

Future<Database> _initDatabase() async {
  try {
    print('🔧 DB: Getting database path...');
    final dbPath = await getDatabasesPath();
    final path = join.join(dbPath, 'todo.db');
    print('🔧 DB: Database path: $path');

    final database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        print('🔧 DB: Creating new database...');
        await _createTables(db);
        print('✅ DB: Database created successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('🔧 DB: Upgrading database from v$oldVersion to v$newVersion');
        if (oldVersion < 2) {
          await _upgradeToVersion2(db);
        }
        print('✅ DB: Database upgraded successfully');
      },
      onOpen: (db) {
        print('✅ DB: Database opened successfully');
      },
    );

    // Verify database schema
    await _verifySchema(database);
    return database;
  } catch (e, stackTrace) {
    print('❌ DB: Database initialization failed: $e');
    print('❌ DB: Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> _createTables(Database db) async {
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
  await db.execute('CREATE INDEX idx_tasks_completed ON tasks(isCompleted)');
  await db.execute('CREATE INDEX idx_tasks_favorite ON tasks(isFavorite)');

  print('✅ DB: Tables and indexes created successfully');
}

Future<void> _upgradeToVersion2(Database db) async {
  try {
    // Add missing columns if upgrading from old schema
    await db.execute('ALTER TABLE tasks ADD COLUMN color INTEGER DEFAULT 0');
    await db.execute(
      'ALTER TABLE tasks ADD COLUMN createdAt TEXT DEFAULT CURRENT_TIMESTAMP',
    );

    // Create indexes if they don't exist
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(isCompleted)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_tasks_favorite ON tasks(isFavorite)',
    );

    print('✅ DB: Database upgraded to version 2');
  } catch (e) {
    print('⚠️ DB: Upgrade error (columns might already exist): $e');
  }
}

Future<void> _verifySchema(Database db) async {
  try {
    final result = await db.rawQuery("PRAGMA table_info(tasks)");
    print('🔧 DB: Verifying schema...');

    final columns = result.map((row) => row['name'] as String).toList();
    final expectedColumns = [
      'id',
      'title',
      'date',
      'startTime',
      'endTime',
      'reminder',
      'repeatInterval',
      'color',
      'isCompleted',
      'isFavorite',
      'createdAt',
    ];

    for (final expectedColumn in expectedColumns) {
      if (!columns.contains(expectedColumn)) {
        throw Exception('Missing column: $expectedColumn');
      }
    }

    print('✅ DB: Schema verification passed');
    print('🔧 DB: Available columns: ${columns.join(', ')}');
  } catch (e) {
    print('❌ DB: Schema verification failed: $e');
    rethrow;
  }
}

# ToDoApp - Complete Documentation

**Clean Architecture Implementation with Flutter & SQLite**

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Directory Structure](#directory-structure)
4. [Database Structure](#database-structure)
5. [Features Implementation](#features-implementation)
6. [Dependency Injection](#dependency-injection)
7. [Known Issues](#known-issues)
8. [Setup Instructions](#setup-instructions)
9. [Testing](#testing)
10. [Future Improvements](#future-improvements)

---

## 📱 Project Overview

ToDoApp is a Flutter application implementing **Clean Architecture** principles for task management.
The app supports task creation, scheduling, categorization, and completion tracking with a modern,
responsive UI supporting both light and dark themes.

### Key Features

- ✅ **Task Management**: Create, update, delete, and complete tasks
- 📅 **Schedule View**: Calendar-based task viewing with date selection
- 📊 **Board View**: Categorized task display (All, Completed, Uncompleted, Favorite)
- 🎨 **Theme Support**: Light/dark mode with consistent theming
- 🔔 **Notifications**: Local notifications for task reminders
- 🏗️ **Clean Architecture**: Proper separation of concerns
- 🧪 **Testable**: Comprehensive testing support

---

## 🏗️ Architecture

The application follows **Clean Architecture** principles with clear separation between:

### **Domain Layer**

- **Entities**: Core business objects (Task, ScheduleDay)
- **Use Cases**: Business logic operations
- **Repositories**: Abstract interfaces for data operations

### **Data Layer**

- **Models**: Data transfer objects extending entities
- **Datasources**: Database operations (SQLite)
- **Repository Implementations**: Concrete repository implementations

### **Presentation Layer**

- **Cubits**: State management using Flutter Bloc
- **Screens**: UI screens and navigation
- **Widgets**: Reusable UI components

---

## 📁 Directory Structure

```
lib/
├── injection_container.dart                 # Dependency Injection Setup
├── main.dart                               # App Entry Point
├── app.dart                                # App Widget Configuration
├── bloc_observer.dart                      # Global Bloc Observer
├── db_cubit.dart                          # Legacy Database Cubit
├── db_state.dart                          # Legacy Database States
└── src/
    ├── config/
    │   ├── routes/
    │   │   └── app_routes.dart            # App Navigation Routes
    │   └── themes/
    │       ├── system/
    │       │   └── system_overlay_style.dart
    │       ├── widgets/
    │       │   ├── app_bar_theme.dart
    │       │   ├── icon_theme.dart
    │       │   ├── tab_bar_theme.dart
    │       │   ├── text_field_theme.dart
    │       │   └── text_theme.dart
    │       └── app_theme.dart             # Main Theme Configuration
    ├── core/
    │   ├── extensions/
    │   │   └── schedule_day_extensions.dart  # ScheduleDay Utility Extensions
    │   ├── services/
    │   │   ├── date_time_service.dart     # Date/Time Picker Service
    │   │   ├── notification_service.dart  # Local Notifications
    │   │   └── popup_menu_service.dart    # Context Menu Service
    │   ├── utils/
    │   │   ├── app_colors.dart           # Color Definitions
    │   │   ├── app_constants.dart        # App Constants
    │   │   ├── app_strings.dart          # String Constants
    │   │   └── media_query_values.dart   # Responsive Utilities
    │   └── widgets/
    │       ├── app_bar_widget.dart       # Custom AppBar
    │       ├── checkbox_widget.dart      # Custom Checkbox
    │       ├── my_button_widget.dart     # Custom Button
    │       └── text_field_widget.dart    # Custom TextField
    └── features/
        ├── add_task/                     # Add Task Feature
        │   ├── data/
        │   │   ├── data_sources/
        │   │   │   └── task_local_data_source.dart
        │   │   ├── models/
        │   │   │   └── task_model.dart
        │   │   └── repositories/
        │   │       └── task_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── task.dart
        │   │   ├── repositories/
        │   │   │   └── task_repository.dart
        │   │   └── use_cases/
        │   │       ├── create_task_use_case.dart
        │   │       ├── delete_task_use_case.dart
        │   │       ├── get_all_tasks_use_case.dart
        │   │       ├── get_completed_tasks_use_case.dart
        │   │       ├── get_favorite_tasks_use_case.dart
        │   │       ├── get_tasks_by_date_range_use_case.dart
        │   │       ├── get_tasks_by_date_use_case.dart
        │   │       ├── get_uncompleted_tasks_use_case.dart
        │   │       ├── update_task_completion_use_case.dart
        │   │       └── update_task_favorite_use_case.dart
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── add_task_cubit.dart
        │       │   └── add_task_state.dart
        │       ├── screens/
        │       │   └── add_task_screen.dart
        │       └── widgets/
        │           ├── add_task_content.dart
        │           └── color_picker_widget.dart
        ├── board/                        # Board Feature
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── board_cubit.dart
        │       │   └── board_state.dart
        │       ├── screens/
        │       │   └── board_screen.dart
        │       ├── views/
        │       │   ├── all_tab_bar_view.dart
        │       │   ├── completed_tab_bar_view.dart
        │       │   ├── favorite_tab_bar_view.dart
        │       │   └── uncompleted_tab_bar_view.dart
        │       └── widgets/
        │           ├── board_content.dart
        │           ├── board_item.dart
        │           └── tab_view_widget.dart
        └── schedule/                     # Schedule Feature
            ├── domain/
            │   └── entities/
            │       └── schedule_day.dart
            └── presentation/
                ├── cubit/
                │   ├── schedule_cubit.dart
                │   └── schedule_state.dart
                ├── screens/
                │   └── schedule_screen.dart
                └── widgets/
                    ├── date_picker_widget.dart
                    ├── schedule_content.dart
                    ├── schedule_item.dart
                    └── schedule_stats_widget.dart
```

---

## 🗄️ Database Structure

### **SQLite Database Schema**

```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  date TEXT NOT NULL,                    -- Format: YYYY-MM-DD
  startTime TEXT NOT NULL,               -- Format: HH:MM
  endTime TEXT NOT NULL,                 -- Format: HH:MM
  reminder TEXT NOT NULL,                -- e.g., "10 min before"
  repeatInterval TEXT NOT NULL,          -- e.g., "None", "Daily", "Weekly"
  color INTEGER NOT NULL DEFAULT 0,     -- Color index (0-3)
  isCompleted INTEGER NOT NULL DEFAULT 0, -- Boolean: 0=false, 1=true
  isFavorite INTEGER NOT NULL DEFAULT 0,  -- Boolean: 0=false, 1=true
  createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Performance Indexes
CREATE INDEX idx_tasks_date ON tasks(date);
CREATE INDEX idx_tasks_completed ON tasks(isCompleted);
CREATE INDEX idx_tasks_favorite ON tasks(isFavorite);
```

### **Database Migration Support**

- **Version 1**: Initial schema
- **Version 2**: Added `color` and `createdAt` columns with proper migration

---

## 🎯 Features Implementation

### **1. Add Task Feature**

#### **Core Components:**

- **Task Entity**: Core business object with all properties
- **TaskModel**: Data transfer object with database conversion methods
- **CreateTaskUseCase**: Validates and creates new tasks
- **AddTaskCubit**: Manages form state and task creation

#### **Key Features:**

- ✅ Form validation with real-time feedback
- ✅ Date/time selection with validation
- ✅ Color selection (4 predefined colors)
- ✅ Reminder and repeat interval selection
- ✅ Notification scheduling

### **2. Board Feature**

#### **Core Components:**

- **BoardCubit**: Manages task lists and filtering
- **Use Cases**: Separate use cases for each filter type
- **Tab Views**: All, Completed, Uncompleted, Favorite
- **BoardItem**: Individual task display with actions

#### **Key Features:**

- ✅ Tab-based task filtering
- ✅ Task completion toggling
- ✅ Favorite marking
- ✅ Task deletion with confirmation
- ✅ Context menu actions
- ✅ Optimistic updates for better UX

### **3. Schedule Feature**

#### **Core Components:**

- **ScheduleCubit**: Manages date-based task viewing
- **ScheduleDay Entity**: Rich date-based task container
- **Date Picker**: Interactive calendar component
- **Schedule Stats**: Progress tracking and statistics

#### **Key Features:**

- ✅ Calendar-based task viewing
- ✅ Daily progress tracking
- ✅ Task completion from schedule view
- ✅ Date range support
- ✅ Visual progress indicators

---

## 🔧 Dependency Injection

### **Setup (injection_container.dart)**

```dart

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Initialize database first
  final database = await _initDatabase();
  sl.registerLazySingleton<Database>(() => database);

  // 2. Register data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
        () => TaskLocalDataSourceImpl(database: sl()),
  );

  // 3. Register repositories
  sl.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(localDatasource: sl()),
  );

  // 4. Register use cases
  sl.registerLazySingleton(() => GetAllTasksUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(repository: sl()));
  // ... other use cases

  // 5. Register cubits
  sl.registerFactory(() =>
      BoardCubit(
        getAllTasksUseCase: sl(),
        // ... other dependencies
      ));
}
```

### **Registration Order:**

1. **Database** (initialized first, synchronously)
2. **Data Sources** (depend on database)
3. **Repositories** (depend on data sources)
4. **Use Cases** (depend on repositories)
5. **Cubits** (depend on use cases)

---

## ⚠️ Known Issues

### **Board Feature Issues**

- **Tab Filtering Problem**: Board doesn't correctly display filtered tasks according to selected
  tab
- **Database Integration**: Tasks from database are not properly displayed in board views
- **UI Enhancement Needed**:
    - Inconsistent paddings between items
    - Tab transitions need smoother animations
    - Loading states not properly implemented
    - Empty states need better messaging

### **Schedule Feature Issues**

- **Database Display Problem**: Schedule doesn't display any tasks from database
- **Date Synchronization**: Selected date doesn't properly sync with task loading
- **Data Refresh**: Manual refresh needed when returning from add task screen

### **General Issues**

- **Legacy Compatibility**: Some components still use old DatabaseCubit instead of clean
  architecture
- **Error Handling**: Inconsistent error handling across features
- **Performance**: Database queries could be optimized with better caching

---

## 🚀 Setup Instructions

### **Prerequisites**

```yaml
# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  sqflite: ^2.3.0
  get_it: ^7.6.4
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0
  flutter_screenutil: ^5.9.0
  fluttertoast: ^8.2.4
  date_picker_timeline: ^1.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.4
  mocktail: ^1.0.0
```

### **Installation Steps**

1. **Clone and Setup**
   ```bash
   git clone <repository>
   cd todo_app
   flutter pub get
   ```

2. **Initialize Dependencies**
   ```dart
   // main.dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await di.init();  // Critical: Wait for DI initialization
     runApp(const ToDoApp());
   }
   ```

3. **Run Application**
   ```bash
   flutter run
   ```

### **Android Permissions**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" /><uses-permission
android:name="android.permission.USE_EXACT_ALARM" />
```

---

## 🧪 Testing

### **Unit Testing Structure**

```
test/
├── features/
│   ├── add_task/
│   │   ├── domain/
│   │   │   └── use_cases/
│   │   │       └── create_task_use_case_test.dart
│   │   └── presentation/
│   │       └── cubit/
│   │           └── add_task_cubit_test.dart
│   ├── board/
│   │   └── presentation/
│   │       └── cubit/
│   │           └── board_cubit_test.dart
│   └── schedule/
│       └── presentation/
│           └── cubit/
│               └── schedule_cubit_test.dart
└── widget_test.dart
```

### **Example Test**

```dart
blocTest<BoardCubit, BoardState>
('loads all tasks successfully
'
,build: () {
when(() => mockGetAllTasksUseCase()).thenAnswer(
(_) async => [testTask],
);
return boardCubit;
},
act: (cubit) => cubit.loadAllTasks(),
expect: () => [
BoardLoading(),
BoardTasksLoaded([testTask], BoardTabType.
all
)
,
]
,
);
```

---

## 🔮 Future Improvements

### **High Priority**

1. **Fix Board Feature**
    - Implement proper tab filtering
    - Fix database integration
    - Enhance UI padding and animations

2. **Fix Schedule Feature**
    - Implement database task display
    - Fix date synchronization
    - Add auto-refresh functionality

### **Medium Priority**

1. **Performance Optimization**
    - Implement task caching
    - Add pagination for large datasets
    - Optimize database queries

2. **Enhanced Features**
    - Task search and filtering
    - Bulk task operations
    - Task categories/projects
    - Data export/import

### **Low Priority**

1. **UI/UX Improvements**
    - Smooth animations
    - Better empty states
    - Enhanced accessibility
    - Tablet support

2. **Architecture Enhancement**
    - Complete migration to clean architecture
    - Remove legacy DatabaseCubit
    - Implement offline-first approach

---

## 📊 Architecture Benefits

### **Achieved**

- ✅ **Testability**: Easy unit testing of business logic
- ✅ **Maintainability**: Clear separation of concerns
- ✅ **Scalability**: Easy to add new features
- ✅ **Flexibility**: Can easily swap data sources

### **In Progress**

- 🟡 **Complete Clean Architecture**: Some legacy components remain
- 🟡 **Error Handling**: Partially implemented
- 🟡 **Performance**: Good foundation, needs optimization

---

## 👥 Contributing

### **Code Style**

- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add proper documentation
- Write unit tests for new features

### **Architecture Guidelines**

- Use clean architecture principles
- Implement proper use cases for business logic
- Keep UI components stateless when possible
- Use dependency injection for all dependencies

---

**Documentation Version**: 1.0  
**Last Updated**: June 2025  
**Flutter Version**: 3.0+  
**Dart Version**: 3.0+
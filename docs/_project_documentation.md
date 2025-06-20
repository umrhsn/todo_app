# ToDoApp Directory Structure

```
todo_app/
├── lib/
│   ├── src/
│   │   ├── config/
│   │   │   └── routes/
│   │   │       └── app_routes.dart
│   │   ├── themes/
│   │   │   ├── system/
│   │   │   │   └── system_overlay_style.dart
│   │   │   ├── widgets/
│   │   │   │   ├── app_bar_theme.dart
│   │   │   │   ├── icon_theme.dart
│   │   │   │   ├── tab_bar_theme.dart
│   │   │   │   ├── text_field_theme.dart
│   │   │   │   └── text_theme.dart
│   │   │   └── app_theme.dart
│   │   ├── core/
│   │   │   ├── services/
│   │   │   │   ├── date_time_service.dart
│   │   │   │   ├── notification_service.dart
│   │   │   │   └── popup_menu_service.dart
│   │   │   ├── utils/
│   │   │   │   ├── app_colors.dart
│   │   │   │   ├── app_constants.dart
│   │   │   │   ├── app_strings.dart
│   │   │   │   └── media_query_values.dart
│   │   │   └── widgets/
│   │   │       ├── app_bar_widget.dart
│   │   │       ├── checkbox_widget.dart
│   │   │       ├── my_button_widget.dart
│   │   │       └── text_field_widget.dart
│   │   └── features/
│   │       ├── add_task/
│   │       │   ├── data/
│   │       │   │   └── data_sources/
│   │       │   │       └── task_local_data_source.dart
│   │       │   ├── domain/
│   │       │   │   └── entities/
│   │       │   │       └── task.dart
│   │       │   └── presentation/
│   │       │       ├── cubit/
│   │       │       │   ├── add_task_cubit.dart
│   │       │       │   └── add_task_state.dart
│   │       │       ├── screens/
│   │       │       │   └── add_task_screen.dart
│   │       │       └── widgets/
│   │       │           ├── add_task_content.dart
│   │       │           └── color_picker_widget.dart
│   │       ├── board/
│   │       │   └── presentation/
│   │       │       ├── cubit/
│   │       │       │   ├── board_cubit.dart
│   │       │       │   └── board_state.dart
│   │       │       ├── screens/
│   │       │       │   └── board_screen.dart
│   │       │       ├── views/
│   │       │       │   ├── all_tab_bar_view.dart
│   │       │       │   ├── completed_tab_bar_view.dart
│   │       │       │   ├── favorite_tab_bar_view.dart
│   │       │       │   └── uncompleted_tab_bar_view.dart
│   │       │       └── widgets/
│   │       │           ├── board_content.dart
│   │       │           ├── board_item.dart
│   │       │           └── tab_view_widget.dart
│   │       └── schedule/
│   │           └── presentation/
│   │               ├── cubit/
│   │               │   ├── schedule_cubit.dart
│   │               │   └── schedule_state.dart
│   │               ├── screens/
│   │               │   └── schedule_screen.dart
│   │               └── widgets/
│   │                   ├── date_picker_widget.dart
│   │                   ├── schedule_content.dart
│   │                   └── schedule_item.dart
│   ├── app.dart
│   ├── bloc_observer.dart
│   ├── db_cubit.dart
│   ├── db_state.dart
│   └── main.dart
└── test/
    └── widget_test.dart
```

## Directory Structure Overview

### **Root Level**

- **lib/** - Main application source code
- **test/** - Test files for the application

### **Core Architecture**

#### **src/config/**

- Contains application configuration files
- **routes/** - Navigation and routing configuration

#### **src/themes/**

- **system/** - System-level theming (status bar, system UI)
- **widgets/** - Individual widget themes (app bar, text fields, etc.)
- **app_theme.dart** - Main theme configuration

#### **src/core/**

- **services/** - Business logic services (notifications, date/time, popup menus)
- **utils/** - Utility classes (colors, constants, strings, responsive design)
- **widgets/** - Reusable UI components

### **Feature-Based Architecture**

#### **features/add_task/**

- **data/** - Data layer with local data sources
- **domain/** - Business logic and entities
- **presentation/** - UI layer with Cubit state management, screens, and widgets

#### **features/board/**

- **presentation/** - Main dashboard with tab-based views
- **views/** - Different filtered views (all, completed, favorite, uncompleted tasks)
- **widgets/** - Board-specific UI components

#### **features/schedule/**

- **presentation/** - Calendar/schedule view functionality
- **widgets/** - Schedule-specific UI components

### **Key Characteristics**

- **Clean Architecture** - Separation of concerns with data, domain, and presentation layers
- **Feature-Driven** - Each major feature has its own module
- **Cubit State Management** - Using Flutter Bloc pattern for state management
- **Reusable Components** - Shared widgets and utilities
- **Theming System** - Comprehensive theme management
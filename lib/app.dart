import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/db_cubit.dart';
import 'package:todo_app/src/config/routes/app_routes.dart';
import 'package:todo_app/src/config/themes/app_theme.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/features/add_task/presentation/cubit/add_task_cubit.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/schedule/presentation/cubit/schedule_cubit.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DatabaseCubit>(
            create: (context) => DatabaseCubit()..initAppDatabase()),
        BlocProvider<BoardCubit>(create: (context) => BoardCubit()),
        BlocProvider<AddTaskCubit>(create: (context) => AddTaskCubit()),
        BlocProvider<ScheduleCubit>(create: (context) => ScheduleCubit()),
      ],
      child: ScreenUtilInit(
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: AppStrings.appName,
            themeMode: ThemeMode.system,
            theme: AppThemes.appTheme(isLight: true),
            darkTheme: AppThemes.appTheme(isLight: false),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.initialRoute,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}

// app.dart (Updated to wait for dependency injection)
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
import 'injection_container.dart' as di;

class ToDoApp extends StatelessWidget {
  const ToDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Keep DatabaseCubit for backward compatibility
        BlocProvider<DatabaseCubit>(
          create: (context) => DatabaseCubit()..initAppDatabase(),
        ),
        // New clean architecture cubits
        BlocProvider<BoardCubit>(create: (context) => di.sl<BoardCubit>()),
        BlocProvider<AddTaskCubit>(create: (context) => di.sl<AddTaskCubit>()),
        BlocProvider<ScheduleCubit>(
          create: (context) => di.sl<ScheduleCubit>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: AppStrings.appName,
            themeMode: ThemeMode.system,
            theme: AppThemes.appTheme(isLight: true),
            darkTheme: AppThemes.appTheme(isLight: false),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.initialRoute,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: widget!,
              );
            },
          );
        },
      ),
    );
  }
}

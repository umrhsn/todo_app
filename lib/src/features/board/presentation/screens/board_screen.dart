import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/config/routes/app_routes.dart';
import 'package:todo_app/src/core/utils/app_constants.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/app_bar_widget.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/board_content.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardCubit>().loadAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBarWidget(
      toolbarHeight: 100,
      title: AppStrings.boardScreenTitle,
      hasActions: true,
      trailingIcon: Icons.calendar_month_outlined,
      trailingIconOnTap: () =>
          Navigator.pushNamed(context, Routes.scheduleRoute),
      bottom: const TabBar(tabs: AppConstants.boardTabs, isScrollable: true),
    );

    return DefaultTabController(
      length: AppConstants.boardTabViewsList.length,
      child: Scaffold(appBar: appBar, body: const BoardContent()),
    );
  }
}

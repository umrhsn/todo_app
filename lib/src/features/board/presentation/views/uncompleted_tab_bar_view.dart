import 'package:flutter/material.dart';
import 'package:todo_app/db_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/tab_view_widget.dart';

class UncompletedTabBarView extends StatefulWidget {
  const UncompletedTabBarView({super.key});

  @override
  State<UncompletedTabBarView> createState() => _UncompletedTabBarViewState();
}

class _UncompletedTabBarViewState extends State<UncompletedTabBarView> {
  @override
  void initState() {
    super.initState();
    DatabaseCubit.get(context).getUnCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return const TabViewWidget();
  }
}

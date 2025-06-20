import 'package:flutter/material.dart';
import 'package:todo_app/db_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/tab_view_widget.dart';

class CompletedTabBarView extends StatefulWidget {
  const CompletedTabBarView({super.key});

  @override
  State<CompletedTabBarView> createState() => _CompletedTabBarViewState();
}

class _CompletedTabBarViewState extends State<CompletedTabBarView> {
  @override
  void initState() {
    super.initState();
    DatabaseCubit.get(context).getCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return const TabViewWidget();
  }
}

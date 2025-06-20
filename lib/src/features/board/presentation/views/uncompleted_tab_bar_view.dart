// presentation/views/uncompleted_tab_bar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
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
    // Load uncompleted tasks when this tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BoardCubit>().loadUncompletedTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TabViewWidget();
  }
}

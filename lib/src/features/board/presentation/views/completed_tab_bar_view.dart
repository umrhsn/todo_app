// presentation/views/completed_tab_bar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
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
    // Load completed tasks when this tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BoardCubit>().loadCompletedTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TabViewWidget(tabType: BoardTabType.completed);
  }
}

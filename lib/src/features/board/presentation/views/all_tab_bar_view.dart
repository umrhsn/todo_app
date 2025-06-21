// presentation/views/all_tab_bar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/tab_view_widget.dart';

class AllTabBarView extends StatefulWidget {
  const AllTabBarView({super.key});

  @override
  State<AllTabBarView> createState() => _AllTabBarViewState();
}

class _AllTabBarViewState extends State<AllTabBarView> {
  @override
  void initState() {
    super.initState();
    // Load all tasks when this tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BoardCubit>().loadAllTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TabViewWidget(tabType: BoardTabType.all);
  }
}

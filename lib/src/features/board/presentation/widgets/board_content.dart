// presentation/widgets/board_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/config/routes/app_routes.dart';
import 'package:todo_app/src/core/utils/app_constants.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/my_button_widget.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';

class BoardContent extends StatefulWidget {
  const BoardContent({super.key});

  @override
  State<BoardContent> createState() => _BoardContentState();
}

class _BoardContentState extends State<BoardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppConstants.boardTabViewsList.length,
      vsync: this,
      initialIndex: 0,
    );

    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) return;

    final boardCubit = context.read<BoardCubit>();

    switch (_tabController.index) {
      case 0:
        boardCubit.setCurrentTab(BoardTabType.all);
        boardCubit.loadAllTasks();
        break;
      case 1:
        boardCubit.setCurrentTab(BoardTabType.completed);
        boardCubit.loadCompletedTasks();
        break;
      case 2:
        boardCubit.setCurrentTab(BoardTabType.uncompleted);
        boardCubit.loadUncompletedTasks();
        break;
      case 3:
        boardCubit.setCurrentTab(BoardTabType.favorite);
        boardCubit.loadFavoriteTasks();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BoardCubit, BoardState>(
      listener: (context, state) {
        if (state is BoardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<BoardCubit>().loadTasks();
                },
              ),
            ),
          );
        } else if (state is BoardTaskDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
          top: 15,
        ),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: AppConstants.boardTabViewsList,
              ),
            ),
            const SizedBox(height: 16),
            MyButtonWidget(
              label: AppStrings.addTaskButtonLabel,
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  Routes.addTaskRoute,
                );
                // Refresh current tab when returning from add task screen
                if (result == true) {
                  context.read<BoardCubit>().loadTasks();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

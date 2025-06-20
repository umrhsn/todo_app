// presentation/widgets/tab_view_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/board_item.dart';

class TabViewWidget extends StatelessWidget {
  const TabViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardCubit, BoardState>(
      builder: (context, state) {
        if (state is BoardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BoardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading tasks',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<BoardCubit>().loadTasks(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is BoardTasksLoaded) {
          if (state.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptyMessage(state.currentTab),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.tasks.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return BoardItem(task: state.tasks[index], index: index);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _getEmptyMessage(BoardTabType tabType) {
    switch (tabType) {
      case BoardTabType.all:
        return 'Add a new task to get started';
      case BoardTabType.completed:
        return 'No completed tasks yet';
      case BoardTabType.uncompleted:
        return 'No pending tasks';
      case BoardTabType.favorite:
        return 'No favorite tasks yet';
    }
  }
}

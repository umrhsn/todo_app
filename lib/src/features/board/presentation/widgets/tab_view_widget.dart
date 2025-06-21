// presentation/widgets/enhanced_tab_view_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/board_item.dart';

class TabViewWidget extends StatelessWidget {
  final BoardTabType tabType;

  const TabViewWidget({super.key, required this.tabType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardCubit, BoardState>(
      builder: (context, state) {
        if (state is BoardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BoardError) {
          return _buildErrorState(context, state.message);
        }

        if (state is BoardTasksLoaded && state.currentTab == tabType) {
          if (state.tasks.isEmpty) {
            return _buildEmptyState(context, tabType);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<BoardCubit>().refreshTasks();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.tasks.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return BoardItem(
                  task: state.tasks[index],
                  index: index,
                );
              },
            ),
          );
        }

        // Show loading for initial state or wrong tab
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => context.read<BoardCubit>().refreshTasks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BoardTabType tabType) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabType) {
      case BoardTabType.all:
        title = 'No tasks yet';
        subtitle = 'Create your first task to get started!';
        icon = Icons.task_alt;
        break;
      case BoardTabType.completed:
        title = 'No completed tasks';
        subtitle = 'Complete some tasks to see them here';
        icon = Icons.check_circle_outline;
        break;
      case BoardTabType.uncompleted:
        title = 'All caught up!';
        subtitle = 'No pending tasks at the moment';
        icon = Icons.schedule;
        break;
      case BoardTabType.favorite:
        title = 'No favorite tasks';
        subtitle = 'Mark tasks as favorite to see them here';
        icon = Icons.favorite_border;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

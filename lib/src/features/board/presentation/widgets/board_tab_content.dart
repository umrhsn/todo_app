// presentation/widgets/board_tab_content.dart (Compact UI)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/config/routes/app_routes.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/my_button_widget.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/board_item.dart';

class BoardTabContent extends StatefulWidget {
  final BoardTabType tabType;

  const BoardTabContent({super.key, required this.tabType});

  @override
  State<BoardTabContent> createState() => _BoardTabContentState();
}

class _BoardTabContentState extends State<BoardTabContent> {
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
                  context.read<BoardCubit>().refreshTasks();
                },
              ),
            ),
          );
        } else if (state is BoardTaskDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Column(
        children: [
          // Compact header with task count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTabTitle(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                BlocBuilder<BoardCubit, BoardState>(
                  builder: (context, state) {
                    int taskCount = 0;
                    if (state is BoardTasksLoaded &&
                        state.currentTab == widget.tabType) {
                      taskCount = state.tasks.length;
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTabColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getTabColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$taskCount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _getTabColor(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Tasks list - takes remaining space
          Expanded(child: _buildTasksList()),

          // Compact add button at bottom
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            child: MyButtonWidget(
              label: AppStrings.addTaskButtonLabel,
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  Routes.addTaskRoute,
                );
                if (result == true && mounted) {
                  context.read<BoardCubit>().refreshTasks();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle() {
    switch (widget.tabType) {
      case BoardTabType.all:
        return 'All Tasks';
      case BoardTabType.completed:
        return 'Completed';
      case BoardTabType.uncompleted:
        return 'Pending';
      case BoardTabType.favorite:
        return 'Favorites';
    }
  }

  Color _getTabColor() {
    switch (widget.tabType) {
      case BoardTabType.all:
        return Colors.blue;
      case BoardTabType.completed:
        return Colors.green;
      case BoardTabType.uncompleted:
        return Colors.orange;
      case BoardTabType.favorite:
        return Colors.red;
    }
  }

  Widget _buildTasksList() {
    return BlocBuilder<BoardCubit, BoardState>(
      builder: (context, state) {
        if (state is BoardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BoardError) {
          return _buildCompactErrorState(state.message);
        }

        if (state is BoardTasksLoaded && state.currentTab == widget.tabType) {
          if (state.tasks.isEmpty) {
            return _buildCompactEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<BoardCubit>().refreshTasks();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: BoardItem(task: task, index: index),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCompactErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
            SizedBox(height: 12.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<BoardCubit>().refreshTasks(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (widget.tabType) {
      case BoardTabType.all:
        title = 'No tasks yet';
        subtitle = 'Add your first task below';
        icon = Icons.task_alt;
        break;
      case BoardTabType.completed:
        title = 'No completed tasks';
        subtitle = 'Complete some tasks to see them here';
        icon = Icons.check_circle_outline;
        break;
      case BoardTabType.uncompleted:
        title = 'All caught up!';
        subtitle = 'No pending tasks';
        icon = Icons.schedule;
        break;
      case BoardTabType.favorite:
        title = 'No favorites';
        subtitle = 'Mark tasks as favorite to see them here';
        icon = Icons.favorite_border;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

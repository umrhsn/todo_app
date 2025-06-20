// presentation/widgets/board_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/core/widgets/checkbox_widget.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';

class BoardItem extends StatelessWidget {
  final Task task;
  final int index;

  const BoardItem({super.key, required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    final taskColor = AppColors
        .tasksColorsList[task.colorIndex % AppColors.tasksColorsList.length];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          CheckboxWidget(
            isChecked: task.isCompleted,
            onChanged: (value) {
              if (value != null) {
                context.read<BoardCubit>().toggleTaskCompletion(task.id, value);
              }
            },
            activeColor: taskColor,
            borderColor: taskColor,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : null,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.startTime.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    '${task.startTime} - ${task.endTime}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          // Favorite indicator
          if (task.isFavorite) ...[
            Icon(Icons.favorite, color: Colors.red, size: 16.sp),
            SizedBox(width: 8.w),
          ],
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20.sp),
            onSelected: (value) => _handleMenuAction(value, task, context),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: task.isCompleted ? 'uncomplete' : 'complete',
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.radio_button_unchecked
                          : Icons.check_circle,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      task.isCompleted ? 'Mark Uncompleted' : 'Mark Completed',
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: task.isFavorite ? 'unfavorite' : 'favorite',
                child: Row(
                  children: [
                    Icon(
                      task.isFavorite ? Icons.favorite_border : Icons.favorite,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      task.isFavorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16.sp, color: Colors.red),
                    SizedBox(width: 8.w),
                    Text('Delete Task', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Task task, BuildContext context) {
    final boardCubit = context.read<BoardCubit>();

    switch (action) {
      case 'complete':
        boardCubit.toggleTaskCompletion(task.id, true);
        break;
      case 'uncomplete':
        boardCubit.toggleTaskCompletion(task.id, false);
        break;
      case 'favorite':
        boardCubit.toggleTaskFavorite(task.id, true);
        break;
      case 'unfavorite':
        boardCubit.toggleTaskFavorite(task.id, false);
        break;
      case 'delete':
        _showDeleteConfirmation(context, task.id, boardCubit);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int taskId,
    BoardCubit boardCubit,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                boardCubit.deleteTask(taskId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

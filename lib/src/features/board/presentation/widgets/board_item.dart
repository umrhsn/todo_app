// presentation/widgets/compact_board_item.dart (Fixed all UI issues)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/core/widgets/checkbox_widget.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/task_details_bottom_sheet.dart';

class BoardItem extends StatelessWidget {
  final Task task;
  final int index;

  const BoardItem({super.key, required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    final taskColor = AppColors
        .tasksColorsList[task.colorIndex % AppColors.tasksColorsList.length];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w), // Minimal margin
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: taskColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: IntrinsicHeight(
            // Fixed: Prevents overflow
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color indicator (fixed width)
                Container(
                  width: 3.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: taskColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                SizedBox(width: 12.w),

                // Checkbox (fixed size)
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CheckboxWidget(
                    isChecked: task.isCompleted,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<BoardCubit>().toggleTaskCompletion(
                          task.id,
                          value,
                        );
                      }
                    },
                    activeColor: taskColor,
                    borderColor: taskColor,
                    scale: 0.9, // Fixed: Provided scale value
                  ),
                ),

                SizedBox(width: 12.w),

                // Task content (flexible with constraints)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title (constrained)
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted ? Colors.grey[500] : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Compact time info (single line with ellipsis)
                      if (task.startTime.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              // Fixed: Use Flexible to prevent overflow
                              child: Text(
                                '${task.startTime} - ${task.endTime}${task.date.isNotEmpty ? " • ${_formatDate(task.date)}" : ""}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Compact actions (fixed width)
                SizedBox(
                  width: 60.w, // Fixed: Constrain actions width
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Favorite indicator (fixed size)
                      if (task.isFavorite) ...[
                        Icon(Icons.favorite, color: Colors.red, size: 14.sp),
                        SizedBox(width: 4.w),
                      ],

                      // Menu button (fixed size)
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                          onSelected: (value) =>
                              _handleMenuAction(value, context),
                          padding: EdgeInsets.zero,
                          iconSize: 16.sp,
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: task.isCompleted
                                  ? 'uncomplete'
                                  : 'complete',
                              height: 36.h,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.isCompleted
                                        ? Icons.radio_button_unchecked
                                        : Icons.check_circle,
                                    size: 14.sp,
                                    color: task.isCompleted
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    task.isCompleted
                                        ? 'Mark Pending'
                                        : 'Complete',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: task.isFavorite
                                  ? 'unfavorite'
                                  : 'favorite',
                              height: 36.h,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.isFavorite
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    size: 14.sp,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    task.isFavorite ? 'Unfavorite' : 'Favorite',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'delete',
                              height: 36.h,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 14.sp,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
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
        _showDeleteConfirmation(context, boardCubit);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, BoardCubit boardCubit) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          contentPadding: EdgeInsets.all(20.w),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('Delete Task', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete this task?', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    fontSize: 12.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                boardCubit.deleteTask(task.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text('Delete', style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => TaskDetailsBottomSheet(task: task),
    );
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        const months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[month]} $day';
      }
    } catch (e) {
      // Fallback to original date if parsing fails
    }
    return date;
  }
}

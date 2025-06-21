import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';

class TaskDetailsBottomSheet extends StatelessWidget {
  final Task task;

  const TaskDetailsBottomSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskColor = AppColors
        .tasksColorsList[task.colorIndex % AppColors.tasksColorsList.length];

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Title with color indicator (fixed layout)
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: taskColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.isFavorite) ...[
                    SizedBox(width: 8.w),
                    Icon(Icons.favorite, color: Colors.red, size: 20.sp),
                  ],
                ],
              ),

              SizedBox(height: 16.h),

              // Compact task details (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _buildCompactDetailRow(
                        Icons.calendar_today,
                        'Date',
                        task.date,
                      ),
                      _buildCompactDetailRow(
                        Icons.access_time,
                        'Time',
                        '${task.startTime} - ${task.endTime}',
                      ),
                      _buildCompactDetailRow(
                        Icons.notifications,
                        'Reminder',
                        task.reminder,
                      ),
                      _buildCompactDetailRow(
                        Icons.repeat,
                        'Repeat',
                        task.repeatInterval,
                      ),
                      _buildCompactDetailRow(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        'Status',
                        task.isCompleted ? 'Completed' : 'Pending',
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Compact action buttons (fixed at bottom)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<BoardCubit>().toggleTaskCompletion(
                          task.id,
                          !task.isCompleted,
                        );
                      },
                      icon: Icon(
                        task.isCompleted ? Icons.undo : Icons.check,
                        size: 16.sp,
                      ),
                      label: Text(
                        task.isCompleted ? 'Mark Pending' : 'Complete',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<BoardCubit>().toggleTaskFavorite(
                          task.id,
                          !task.isFavorite,
                        );
                      },
                      icon: Icon(
                        task.isFavorite
                            ? Icons.favorite_border
                            : Icons.favorite,
                        size: 16.sp,
                      ),
                      label: Text(
                        task.isFavorite ? 'Unfavorite' : 'Favorite',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey[600]),
          SizedBox(width: 12.w),
          SizedBox(
            width: 60.w, // Fixed width for labels
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

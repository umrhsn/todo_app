// Fixed board_item.dart - Proper color mapping and enhanced UI
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
    // Fixed: Ensure color index is within bounds
    final colorIndex = task.colorIndex.clamp(
      0,
      AppColors.tasksColorsList.length - 1,
    );
    final taskColor = AppColors.tasksColorsList[colorIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    debugPrint(
      '🎨 BoardItem: Rendering task ${task.id} with color index $colorIndex (${task.colorIndex})',
    );
    debugPrint('🎨 BoardItem: Task color: $taskColor');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: taskColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: taskColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTaskDetails(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced color indicator
                Container(
                  width: 4.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [taskColor, taskColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                    boxShadow: [
                      BoxShadow(
                        color: taskColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(1, 0),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                // Enhanced checkbox
                Container(
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? taskColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.all(2.w),
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
                    scale: 1.0,
                  ),
                ),

                SizedBox(width: 16.w),

                // Enhanced task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with enhanced styling
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted
                              ? Colors.grey[500]
                              : (isDarkMode ? Colors.white : Colors.black87),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8.h),

                      // Enhanced time and date info
                      if (task.startTime.isNotEmpty &&
                          task.endTime.isNotEmpty) ...[
                        _buildInfoRow(
                          icon: Icons.schedule,
                          text: '${task.startTime} - ${task.endTime}',
                          color: taskColor,
                        ),
                        SizedBox(height: 4.h),
                      ],

                      if (task.date.isNotEmpty) ...[
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          text: _formatDate(task.date),
                          color: Colors.grey[600]!,
                        ),
                        SizedBox(height: 4.h),
                      ],

                      if (task.reminder.isNotEmpty &&
                          task.reminder != 'None') ...[
                        _buildInfoRow(
                          icon: Icons.notifications_outlined,
                          text: task.reminder,
                          color: Colors.orange[600]!,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // Enhanced actions column
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite indicator with animation
                    if (task.isFavorite) ...[
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],

                    // Enhanced menu button
                    Container(
                      decoration: BoxDecoration(
                        color: taskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 18.sp,
                          color: taskColor,
                        ),
                        onSelected: (value) =>
                            _handleMenuAction(value, context),
                        padding: EdgeInsets.all(4.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        itemBuilder: (context) => [
                          _buildPopupMenuItem(
                            value: task.isCompleted ? 'uncomplete' : 'complete',
                            icon: task.isCompleted
                                ? Icons.radio_button_unchecked
                                : Icons.check_circle,
                            text: task.isCompleted
                                ? 'Mark Pending'
                                : 'Complete',
                            color: task.isCompleted
                                ? Colors.orange
                                : Colors.green,
                          ),
                          _buildPopupMenuItem(
                            value: task.isFavorite ? 'unfavorite' : 'favorite',
                            icon: task.isFavorite
                                ? Icons.favorite_border
                                : Icons.favorite,
                            text: task.isFavorite ? 'Unfavorite' : 'Favorite',
                            color: Colors.red,
                          ),
                          const PopupMenuDivider(),
                          _buildPopupMenuItem(
                            value: 'delete',
                            icon: Icons.delete_outline,
                            text: 'Delete',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 40.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: value == 'delete' ? Colors.red : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            borderRadius: BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.all(24.w),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Delete Task',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this task?',
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                boardCubit.deleteTask(task.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailsBottomSheet(task: task),
    );
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        final now = DateTime.now();
        final taskDate = DateTime(year, month, day);
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));

        if (taskDate == today) {
          return 'Today';
        } else if (taskDate == tomorrow) {
          return 'Tomorrow';
        } else if (taskDate == yesterday) {
          return 'Yesterday';
        }

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
      debugPrint('Error formatting date: $e');
    }
    return date;
  }
}

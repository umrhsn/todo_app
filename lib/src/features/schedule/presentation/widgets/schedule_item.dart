// presentation/widgets/schedule_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/core/widgets/checkbox_widget.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';

class ScheduleItem extends StatelessWidget {
  final Task task;
  final Function(bool?)? onCompletionChanged;

  const ScheduleItem({super.key, required this.task, this.onCompletionChanged});

  @override
  Widget build(BuildContext context) {
    final taskColor = AppColors
        .tasksColorsList[task.colorIndex % AppColors.tasksColorsList.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.only(
            top: 17,
            left: 17,
            bottom: 17,
            right: 10,
          ),
          color: taskColor.withOpacity(task.isCompleted ? 0.6 : 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.startTime.isNotEmpty) ...[
                      Text(
                        '${task.startTime} - ${task.endTime}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      task.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.reminder.isNotEmpty &&
                        task.reminder != '10 min before') ...[
                      const SizedBox(height: 2),
                      Text(
                        'Reminder: ${task.reminder}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.isFavorite) ...[
                    Icon(Icons.favorite, color: Colors.white, size: 16.sp),
                    const SizedBox(width: 8),
                  ],
                  CheckboxWidget(
                    isChecked: task.isCompleted,
                    isCircular: true,
                    onChanged: onCompletionChanged,
                    activeColor: taskColor,
                    borderColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

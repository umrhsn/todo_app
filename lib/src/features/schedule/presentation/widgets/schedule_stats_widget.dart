// presentation/widgets/schedule_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/core/utils/media_query_values.dart';
import 'package:todo_app/src/features/schedule/presentation/cubit/schedule_cubit.dart';

class ScheduleStatsWidget extends StatelessWidget {
  const ScheduleStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLight = context.platformBrightness == Brightness.light;

    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        if (state is! ScheduleTasksLoaded) {
          return const SizedBox.shrink();
        }

        final scheduleDay = state.scheduleDay;

        if (scheduleDay.hasNoTasks) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isLight ? Colors.grey[100] : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Progress circle
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: CircularProgressIndicator(
                  value: scheduleDay.completionPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLight ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                  strokeWidth: 4,
                ),
              ),

              SizedBox(width: 16.w),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${scheduleDay.completedCount}/${scheduleDay.totalCount} completed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${(scheduleDay.completionPercentage * 100).round()}% progress',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              if (scheduleDay.hasCompletedAll) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Complete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

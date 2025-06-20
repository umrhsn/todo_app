// presentation/widgets/schedule_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:todo_app/src/features/schedule/presentation/widgets/date_picker_widget.dart';
import 'package:todo_app/src/features/schedule/presentation/widgets/schedule_item.dart';
import 'package:todo_app/src/features/schedule/presentation/widgets/schedule_stats_widget.dart';

class ScheduleContent extends StatefulWidget {
  const ScheduleContent({super.key});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleCubit, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<ScheduleCubit>().refreshCurrentDate();
                },
              ),
            ),
          );
        }
      },
      child: Column(
        children: [
          // Date picker
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              final cubit = context.read<ScheduleCubit>();
              return DatePickerWidget(
                startDate: DateTime.now().subtract(const Duration(days: 365)),
                selectedDate: cubit.selectedDate,
                initialSelectedDate: cubit.selectedDate,
                onDateChanged: (date) {
                  context.read<ScheduleCubit>().loadTasksForDate(date);
                },
              );
            },
          ),

          const Divider(thickness: 2),

          // Date info and stats
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              final cubit = context.read<ScheduleCubit>();
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cubit.formattedSelectedDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.h,
                      ),
                    ),
                    if (state is ScheduleTasksLoaded) ...[
                      Text(
                        '${state.scheduleDay.totalCount} tasks',
                        style: TextStyle(fontSize: 12.h),
                      ),
                    ] else ...[
                      Text('0 tasks', style: TextStyle(fontSize: 12.h)),
                    ],
                  ],
                ),
              );
            },
          ),

          // Schedule stats
          const ScheduleStatsWidget(),

          // Tasks list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
              child: _buildTasksList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ScheduleError) {
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
                  onPressed: () =>
                      context.read<ScheduleCubit>().refreshCurrentDate(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ScheduleTasksLoaded) {
          if (state.scheduleDay.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks for this day',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Schedule some tasks to see them here',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: state.scheduleDay.tasks.length,
            itemBuilder: (context, index) {
              final task = state.scheduleDay.tasks[index];
              return ScheduleItem(
                task: task,
                onCompletionChanged: (isCompleted) {
                  context.read<ScheduleCubit>().toggleTaskCompletion(
                    task.id,
                    isCompleted ?? false,
                  );
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

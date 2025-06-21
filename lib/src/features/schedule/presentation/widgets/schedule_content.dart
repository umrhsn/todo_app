// presentation/widgets/schedule_content.dart (Fixed with proper debugging)
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
  void initState() {
    super.initState();
    debugPrint('🔧 ScheduleContent: initState called');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleCubit, ScheduleState>(
      listener: (context, state) {
        debugPrint('🔧 ScheduleContent: State changed to ${state.runtimeType}');

        if (state is ScheduleError) {
          debugPrint('❌ ScheduleContent: Error state - ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
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

        if (state is ScheduleTasksLoaded) {
          debugPrint(
            '✅ ScheduleContent: Tasks loaded - ${state.scheduleDay.tasks.length} tasks',
          );
        }
      },
      child: Column(
        children: [
          // Date picker
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              final cubit = context.read<ScheduleCubit>();
              debugPrint(
                '🔧 ScheduleContent: Building date picker, selected: ${cubit.selectedDate}',
              );

              return DatePickerWidget(
                startDate: DateTime.now().subtract(const Duration(days: 365)),
                selectedDate: cubit.selectedDate,
                initialSelectedDate: cubit.selectedDate,
                onDateChanged: (date) {
                  debugPrint('📅 ScheduleContent: Date changed to: $date');
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
              int taskCount = 0;

              if (state is ScheduleTasksLoaded) {
                taskCount = state.scheduleDay.totalCount;
              }

              debugPrint(
                '🔧 ScheduleContent: Building header, task count: $taskCount',
              );

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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: taskCount > 0
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: taskCount > 0 ? Colors.blue : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$taskCount tasks',
                        style: TextStyle(
                          fontSize: 12.h,
                          fontWeight: FontWeight.w600,
                          color: taskCount > 0
                              ? Colors.blue[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Schedule stats (only show if has tasks)
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              if (state is ScheduleTasksLoaded &&
                  state.scheduleDay.totalCount > 0) {
                return const ScheduleStatsWidget();
              }
              return const SizedBox.shrink();
            },
          ),

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
        debugPrint(
          '🔧 ScheduleContent: Building tasks list, state: ${state.runtimeType}',
        );

        if (state is ScheduleLoading) {
          debugPrint('⏳ ScheduleContent: Showing loading state');
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading tasks...'),
              ],
            ),
          );
        }

        if (state is ScheduleError) {
          debugPrint('❌ ScheduleContent: Showing error state');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
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
          debugPrint(
            '✅ ScheduleContent: Tasks loaded, count: ${state.scheduleDay.tasks.length}',
          );

          if (state.scheduleDay.tasks.isEmpty) {
            debugPrint('📭 ScheduleContent: No tasks for this day');
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
                    'Your schedule is clear for today!',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          debugPrint(
            '📋 ScheduleContent: Rendering ${state.scheduleDay.tasks.length} tasks',
          );
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: state.scheduleDay.tasks.length,
            itemBuilder: (context, index) {
              final task = state.scheduleDay.tasks[index];
              debugPrint(
                '📋 ScheduleContent: Rendering task ${task.id}: ${task.title}',
              );

              return ScheduleItem(
                task: task,
                onCompletionChanged: (isCompleted) {
                  debugPrint(
                    '🔄 ScheduleContent: Task completion changed - ${task.id}: $isCompleted',
                  );
                  context.read<ScheduleCubit>().toggleTaskCompletion(
                    task.id,
                    isCompleted ?? false,
                  );
                },
              );
            },
          );
        }

        debugPrint('❓ ScheduleContent: Unknown state, showing empty');
        return const SizedBox.shrink();
      },
    );
  }
}

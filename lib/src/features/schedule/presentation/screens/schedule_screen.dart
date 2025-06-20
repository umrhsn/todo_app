// presentation/screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/app_bar_widget.dart';
import 'package:todo_app/src/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:todo_app/src/features/schedule/presentation/widgets/schedule_content.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks for today when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleCubit>().loadTasksForDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        leadingIcon: Icons.arrow_back,
        leadingIconOnTap: () => Navigator.pop(context),
        title: AppStrings.scheduleScreenTitle,
      ),
      body: const ScheduleContent(),
    );
  }
}

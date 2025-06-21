// presentation/screens/schedule_screen.dart (Fixed initialization)
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
    debugPrint('🔧 ScheduleScreen: initState called');

    // Ensure cubit loads tasks immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ScheduleCubit>();
      debugPrint(
        '🔧 ScheduleScreen: Loading tasks for today: ${DateTime.now()}',
      );
      cubit.loadTasksForDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        hasLeadingIcon: true,
        leadingIcon: Icons.arrow_back,
        leadingIconOnTap: () => Navigator.pop(context),
        title: AppStrings.scheduleScreenTitle,
      ),
      body: const ScheduleContent(),
    );
  }
}

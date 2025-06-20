import 'package:flutter/material.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/app_bar_widget.dart';
import 'package:todo_app/src/features/schedule/presentation/widgets/schedule_content.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Widget _buildBodyContent() {
    return const ScheduleContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
          leadingIcon: Icons.arrow_back,
          leadingIconOnTap: () => Navigator.pop(context),
          title: AppStrings.scheduleScreenTitle),
      body: _buildBodyContent(),
    );
  }
}

// Fixed add_task_content.dart - Using Clean Architecture and Fixed Time Logic
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/src/config/routes/app_routes.dart';
import 'package:todo_app/src/core/services/date_time_service.dart';
import 'package:todo_app/src/core/services/notification_service.dart';
import 'package:todo_app/src/core/services/popup_menu_service.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/my_button_widget.dart';
import 'package:todo_app/src/core/widgets/text_field_widget.dart';
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/add_task/presentation/cubit/add_task_cubit.dart';
import 'package:todo_app/src/features/add_task/presentation/widgets/color_picker_widget.dart';

class AddTaskContent extends StatefulWidget {
  const AddTaskContent({super.key});

  @override
  State<AddTaskContent> createState() => _AddTaskContentState();
}

class _AddTaskContentState extends State<AddTaskContent> {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final remindController = TextEditingController();
  final repeatController = TextEditingController();

  // Date/Time state
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  int _selectedColor = 0;

  @override
  void initState() {
    super.initState();
    _initializeDefaultValues();
  }

  void _initializeDefaultValues() {
    // Set default date to today
    _selectedDate = DateTime.now();
    dateController.text = _formatDate(_selectedDate);

    // Set default reminder and repeat
    remindController.text = AppStrings.reminderList[0];
    repeatController.text = AppStrings.repeatList[0];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool _isValidTimeRange() {
    if (_startDateTime == null || _endDateTime == null) return true;
    return _endDateTime!.isAfter(_startDateTime!);
  }

  Duration? _getNotificationDuration() {
    if (_startDateTime == null) return null;
    return _startDateTime!.difference(DateTime.now());
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    remindController.dispose();
    repeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddTaskCubit, AddTaskState>(
      listener: (context, state) {
        if (state is AddTaskLoaded) {
          Fluttertoast.showToast(
            msg: 'Task created successfully!',
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.green,
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.initialRoute,
            (route) => false,
          );
        } else if (state is AddTaskError) {
          Fluttertoast.showToast(
            msg: state.message,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
          );
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildTitleField(),
                          const SizedBox(height: 25),
                          _buildDateField(),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(child: _buildStartTimeField()),
                              const SizedBox(width: 20),
                              Expanded(child: _buildEndTimeField()),
                            ],
                          ),
                          if (!_isValidTimeRange()) ...[
                            const SizedBox(height: 8),
                            Text(
                              'End time must be after start time',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 25),
                          _buildReminderField(),
                          const SizedBox(height: 25),
                          _buildRepeatField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    ColorPickerWidget(
                      selectedColor: _selectedColor,
                      onColorChanged: (colorIndex) {
                        setState(() {
                          _selectedColor = colorIndex;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildCreateButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFieldWidget(
      readOnly: false,
      controller: titleController,
      label: AppStrings.titleTextFieldLabel,
      hintText: 'Design team meeting',
      suffixIcon: null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Task title is required';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFieldWidget(
      controller: dateController,
      label: AppStrings.dateTextFieldLabel,
      hintText: _formatDate(_selectedDate),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
            dateController.text = _formatDate(date);
            // Reset times when date changes
            _startDateTime = null;
            _endDateTime = null;
            startTimeController.clear();
            endTimeController.clear();
          });
        }
      },
      keyboardType: TextInputType.datetime,
    );
  }

  Widget _buildStartTimeField() {
    return TextFieldWidget(
      controller: startTimeController,
      label: AppStrings.startTimeTextFieldLabel,
      hintText: 'Select start time',
      suffixIcon: Icons.access_time_rounded,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          final startDateTime = _combineDateAndTime(_selectedDate, time);

          // Only check if time is in past for today's date
          if (_selectedDate.day == DateTime.now().day &&
              _selectedDate.month == DateTime.now().month &&
              _selectedDate.year == DateTime.now().year &&
              startDateTime.isBefore(DateTime.now())) {
            Fluttertoast.showToast(
              msg: "Can't select a time in the past for today",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.orange,
            );
            return;
          }

          setState(() {
            _startDateTime = startDateTime;
            startTimeController.text = _formatTime(startDateTime);

            // Auto-set end time to 1 hour later if not set
            if (_endDateTime == null) {
              _endDateTime = startDateTime.add(const Duration(hours: 1));
              endTimeController.text = _formatTime(_endDateTime!);
            }
          });
        }
      },
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Start time is required';
        }
        return null;
      },
    );
  }

  Widget _buildEndTimeField() {
    return TextFieldWidget(
      controller: endTimeController,
      label: AppStrings.endTimeTextFieldLabel,
      hintText: 'Select end time',
      suffixIcon: Icons.access_time_rounded,
      onTap: () async {
        if (_startDateTime == null) {
          Fluttertoast.showToast(
            msg: "Please select start time first",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.orange,
          );
          return;
        }

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
            _startDateTime!.add(const Duration(hours: 1)),
          ),
        );
        if (time != null) {
          final endDateTime = _combineDateAndTime(_selectedDate, time);

          if (endDateTime.isBefore(_startDateTime!) ||
              endDateTime.isAtSameMomentAs(_startDateTime!)) {
            Fluttertoast.showToast(
              msg: "End time must be after start time",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red,
            );
            return;
          }

          setState(() {
            _endDateTime = endDateTime;
            endTimeController.text = _formatTime(endDateTime);
          });
        }
      },
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'End time is required';
        }
        return null;
      },
    );
  }

  Widget _buildReminderField() {
    List<PopupMenuItem> reminderMenuItems = AppStrings.reminderList
        .map(
          (reminder) => PopupMenuItem(
            value: reminder,
            child: Text(reminder),
            onTap: () => remindController.text = reminder,
          ),
        )
        .toList();

    return TextFieldWidget(
      controller: remindController,
      label: AppStrings.remindTextFieldLabel,
      hintText: 'Select reminder',
      suffixIconOnTapDown: (details) => PopupMenuService(
        context,
      ).showPopupMenuAtPosition(details, reminderMenuItems),
    );
  }

  Widget _buildRepeatField() {
    List<PopupMenuItem> repeatMenuItems = AppStrings.repeatList
        .map(
          (repeat) => PopupMenuItem(
            value: repeat,
            child: Text(repeat),
            onTap: () => repeatController.text = repeat,
          ),
        )
        .toList();

    return TextFieldWidget(
      controller: repeatController,
      label: AppStrings.repeatTextFieldLabel,
      hintText: 'Select repeat',
      suffixIconOnTapDown: (details) => PopupMenuService(
        context,
      ).showPopupMenuAtPosition(details, repeatMenuItems),
    );
  }

  Widget _buildCreateButton() {
    return BlocBuilder<AddTaskCubit, AddTaskState>(
      builder: (context, state) {
        final isLoading = state is AddTaskLoading;

        return MyButtonWidget(
          onPressed: isLoading ? null : _createTask,
          label: isLoading ? 'Creating...' : AppStrings.createTaskButtonLabel,
        );
      },
    );
  }

  void _createTask() async {
    if (!formKey.currentState!.validate()) return;

    if (!_isValidTimeRange()) {
      Fluttertoast.showToast(
        msg: "Please fix the time range",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_startDateTime == null || _endDateTime == null) {
      Fluttertoast.showToast(
        msg: "Please select start and end times",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Schedule notification if task is in the future
    final notificationDuration = _getNotificationDuration();
    if (notificationDuration != null && !notificationDuration.isNegative) {
      try {
        NotificationService(
          _startDateTime!,
        ).scheduleAlarm(timeDifference: notificationDuration);

        final minutes = notificationDuration.inMinutes;
        Fluttertoast.showToast(
          msg: 'Reminder set for $minutes minutes from now',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.blue,
        );
      } catch (e) {
        debugPrint('Notification scheduling failed: $e');
      }
    }

    final task = Task(
      id: 0,
      // Will be auto-generated
      title: titleController.text.trim(),
      date: _formatDate(_selectedDate),
      startTime: _formatTime(_startDateTime!),
      endTime: _formatTime(_endDateTime!),
      reminder: remindController.text.isNotEmpty
          ? remindController.text
          : 'None',
      repeatInterval: repeatController.text.isNotEmpty
          ? repeatController.text
          : 'None',
      colorIndex: _selectedColor,
      isCompleted: false,
      isFavorite: false,
      createdAt: DateTime.now(),
    );

    debugPrint(
      'Creating task: ${task.title} on ${task.date} from ${task.startTime} to ${task.endTime}',
    );
    debugPrint('Task color index: ${task.colorIndex}');

    context.read<AddTaskCubit>().createTask(task);
  }
}

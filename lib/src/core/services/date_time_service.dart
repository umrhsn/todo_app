// Enhanced date_time_service.dart - Fixed time validation logic
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DateTimeService {
  DateTime dateTime;

  DateTimeService({required this.dateTime});

  Future<DateTime?> setDateText(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dateTime.isAfter(DateTime.now()) ? dateTime : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: 'Select task date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (date == null) return null;

    // Update the internal dateTime but preserve time if it exists
    dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      dateTime.hour,
      dateTime.minute,
    );

    controller.text = _formatDate(date);
    debugPrint('📅 DateTimeService: Date selected: ${_formatDate(date)}');
    return dateTime;
  }

  Future<DateTime?> setTimeText(
    BuildContext context, {
    required TextEditingController controller,
    required String hour,
    required String minute,
    bool isEndTime = false,
    DateTime? startTime,
  }) async {
    // Calculate initial time
    TimeOfDay initialTime;
    if (isEndTime && startTime != null) {
      // For end time, suggest 1 hour after start time
      final suggestedEndTime = startTime.add(const Duration(hours: 1));
      initialTime = TimeOfDay.fromDateTime(suggestedEndTime);
    } else {
      // For start time, use current time or existing dateTime
      initialTime = TimeOfDay.fromDateTime(dateTime);
    }

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isEndTime ? 'Select end time' : 'Select start time',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time == null) return null;

    // Create the full datetime
    final selectedDateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      time.hour,
      time.minute,
    );

    // Enhanced validation logic
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Only validate against current time if the selected date is today
    if (selectedDate == today && selectedDateTime.isBefore(now)) {
      Fluttertoast.showToast(
        msg: "Cannot select a time in the past for today",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return null;
    }

    // Validate end time is after start time
    if (isEndTime && startTime != null) {
      if (selectedDateTime.isBefore(startTime) ||
          selectedDateTime.isAtSameMomentAs(startTime)) {
        Fluttertoast.showToast(
          msg: "End time must be after start time",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return null;
      }

      // Check if end time is too far from start time (more than 12 hours)
      final duration = selectedDateTime.difference(startTime);
      if (duration.inHours > 12) {
        final result = await _showDurationWarning(context, duration);
        if (!result) return null;
      }
    }

    dateTime = selectedDateTime;
    controller.text = _formatTime(selectedDateTime);

    debugPrint(
      '⏰ DateTimeService: Time selected: ${_formatTime(selectedDateTime)}',
    );
    debugPrint('⏰ DateTimeService: Full datetime: $selectedDateTime');

    return selectedDateTime;
  }

  Future<bool> _showDurationWarning(
    BuildContext context,
    Duration duration,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Long Duration'),
            content: Text(
              'This task will last ${duration.inHours} hours and ${duration.inMinutes % 60} minutes. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Utility methods for time calculations
  Duration getTimeDifference(DateTime startTime, DateTime endTime) {
    return endTime.difference(startTime);
  }

  Duration getTimeUntilTask(DateTime taskTime) {
    return taskTime.difference(DateTime.now());
  }

  bool isTaskInPast(DateTime taskTime) {
    return taskTime.isBefore(DateTime.now());
  }

  bool isTaskToday(DateTime taskTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(taskTime.year, taskTime.month, taskTime.day);
    return taskDate == today;
  }

  bool isTaskTomorrow(DateTime taskTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final taskDate = DateTime(taskTime.year, taskTime.month, taskTime.day);
    return taskDate == tomorrow;
  }

  String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final difference = taskDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1 && difference >= -7) {
      return '${difference.abs()} days ago';
    } else {
      return _formatDate(date);
    }
  }
}

// Enhanced task.dart - Better validation and color handling
import 'package:equatable/equatable.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String reminder;
  final String repeatInterval;
  final int colorIndex;
  final bool isCompleted;
  final bool isFavorite;
  final DateTime? createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reminder,
    required this.repeatInterval,
    required this.colorIndex,
    required this.isCompleted,
    required this.isFavorite,
    this.createdAt,
  });

  // Enhanced copyWith method
  Task copyWith({
    int? id,
    String? title,
    String? date,
    String? startTime,
    String? endTime,
    String? reminder,
    String? repeatInterval,
    int? colorIndex,
    bool? isCompleted,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminder: reminder ?? this.reminder,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      colorIndex: colorIndex ?? this.colorIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Enhanced validation methods
  bool get isValid {
    return title.trim().isNotEmpty &&
        title.trim().length >= 3 &&
        date.isNotEmpty &&
        _isValidDateFormat(date) &&
        startTime.isNotEmpty &&
        _isValidTimeFormat(startTime) &&
        endTime.isNotEmpty &&
        _isValidTimeFormat(endTime) &&
        _isValidColorIndex(colorIndex);
  }

  bool _isValidDateFormat(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(date)) return false;

    try {
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final dateTime = DateTime(year, month, day);
      return dateTime.year == year &&
          dateTime.month == month &&
          dateTime.day == day;
    } catch (e) {
      return false;
    }
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^\d{1,2}:\d{2}$');
    if (!regex.hasMatch(time)) return false;

    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  bool _isValidColorIndex(int index) {
    return index >= 0 && index < AppColors.tasksColorsList.length;
  }

  // Helper methods
  DateTime? get startDateTime {
    try {
      return _parseDateTime(date, startTime);
    } catch (e) {
      return null;
    }
  }

  DateTime? get endDateTime {
    try {
      return _parseDateTime(date, endTime);
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseDateTime(String dateStr, String timeStr) {
    final dateParts = dateStr.split('-');
    final timeParts = timeStr.split(':');

    return DateTime(
      int.parse(dateParts[0]), // year
      int.parse(dateParts[1]), // month
      int.parse(dateParts[2]), // day
      int.parse(timeParts[0]), // hour
      int.parse(timeParts[1]), // minute
    );
  }

  Duration? get duration {
    final start = startDateTime;
    final end = endDateTime;
    if (start == null || end == null) return null;
    return end.difference(start);
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = _parseDate(date);
    if (taskDate == null) return false;
    return DateTime(taskDate.year, taskDate.month, taskDate.day) == today;
  }

  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final taskDate = _parseDate(date);
    if (taskDate == null) return false;
    return DateTime(taskDate.year, taskDate.month, taskDate.day) == tomorrow;
  }

  bool get isOverdue {
    final taskEnd = endDateTime;
    if (taskEnd == null) return false;
    return !isCompleted && taskEnd.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    final taskStart = startDateTime;
    if (taskStart == null) return false;
    return !isCompleted && taskStart.isAfter(DateTime.now());
  }

  bool get isInProgress {
    final now = DateTime.now();
    final taskStart = startDateTime;
    final taskEnd = endDateTime;
    if (taskStart == null || taskEnd == null) return false;
    return !isCompleted && now.isAfter(taskStart) && now.isBefore(taskEnd);
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }

  String get formattedDate {
    final taskDate = _parseDate(date);
    if (taskDate == null) return date;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    if (taskDateOnly == today) {
      return 'Today';
    } else if (taskDateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDateOnly == today.subtract(const Duration(days: 1))) {
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

    return '${months[taskDate.month]} ${taskDate.day}';
  }

  String get formattedTimeRange {
    if (startTime.isEmpty || endTime.isEmpty) return '';
    return '$startTime - $endTime';
  }

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (isInProgress) return 'In Progress';
    if (isUpcoming) return 'Upcoming';
    return 'Pending';
  }

  // Validation error messages
  List<String> get validationErrors {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Task title is required');
    } else if (title.trim().length < 3) {
      errors.add('Task title must be at least 3 characters');
    }

    if (date.isEmpty) {
      errors.add('Date is required');
    } else if (!_isValidDateFormat(date)) {
      errors.add('Invalid date format (YYYY-MM-DD required)');
    }

    if (startTime.isEmpty) {
      errors.add('Start time is required');
    } else if (!_isValidTimeFormat(startTime)) {
      errors.add('Invalid start time format (HH:MM required)');
    }

    if (endTime.isEmpty) {
      errors.add('End time is required');
    } else if (!_isValidTimeFormat(endTime)) {
      errors.add('Invalid end time format (HH:MM required)');
    }

    if (!_isValidColorIndex(colorIndex)) {
      errors.add('Invalid color selection');
    }

    // Validate time range
    final start = startDateTime;
    final end = endDateTime;
    if (start != null && end != null && !end.isAfter(start)) {
      errors.add('End time must be after start time');
    }

    return errors;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    date,
    startTime,
    endTime,
    reminder,
    repeatInterval,
    colorIndex,
    isCompleted,
    isFavorite,
    createdAt,
  ];

  @override
  String toString() {
    return 'Task(id: $id, title: $title, date: $date, startTime: $startTime, endTime: $endTime, reminder: $reminder, repeatInterval: $repeatInterval, colorIndex: $colorIndex, isCompleted: $isCompleted, isFavorite: $isFavorite, createdAt: $createdAt)';
  }
}

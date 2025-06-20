// Enhanced ScheduleDay utility methods
import 'package:todo_app/src/features/add_task/domain/entities/task.dart';
import 'package:todo_app/src/features/schedule/domain/entities/schedule_day.dart';

extension ScheduleDayExtensions on ScheduleDay {
  List<Task> get pendingTasks =>
      tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList();

  List<Task> get favoriteTasks =>
      tasks.where((task) => task.isFavorite).toList();

  List<Task> get morningTasks {
    return tasks.where((task) {
      final hour = _extractHour(task.startTime);
      return hour >= 6 && hour < 12;
    }).toList();
  }

  List<Task> get afternoonTasks {
    return tasks.where((task) {
      final hour = _extractHour(task.startTime);
      return hour >= 12 && hour < 18;
    }).toList();
  }

  List<Task> get eveningTasks {
    return tasks.where((task) {
      final hour = _extractHour(task.startTime);
      return hour >= 18 || hour < 6;
    }).toList();
  }

  int _extractHour(String timeString) {
    try {
      final parts = timeString.split(':');
      return int.parse(parts[0]);
    } catch (e) {
      return 0;
    }
  }
}

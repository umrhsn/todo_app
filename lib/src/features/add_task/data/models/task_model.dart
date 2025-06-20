// data/models/task_model.dart

import 'package:todo_app/src/features/add_task/domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.reminder,
    required super.repeatInterval,
    required super.colorIndex,
    required super.isCompleted,
    required super.isFavorite,
    super.createdAt,
  });

  // Convert from database map to TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      date: map['date'] as String? ?? '',
      startTime: map['startTime'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      reminder: map['reminder'] as String? ?? '',
      repeatInterval: map['repeatInterval'] as String? ?? '',
      colorIndex: map['color'] as int? ?? 0,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  // Convert from Task entity to TaskModel
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      date: task.date,
      startTime: task.startTime,
      endTime: task.endTime,
      reminder: task.reminder,
      repeatInterval: task.repeatInterval,
      colorIndex: task.colorIndex,
      isCompleted: task.isCompleted,
      isFavorite: task.isFavorite,
      createdAt: task.createdAt,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'reminder': reminder,
      'repeatInterval': repeatInterval,
      'color': colorIndex,
      'isCompleted': isCompleted ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Convert to Task entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      reminder: reminder,
      repeatInterval: repeatInterval,
      colorIndex: colorIndex,
      isCompleted: isCompleted,
      isFavorite: isFavorite,
      createdAt: createdAt,
    );
  }

  @override
  TaskModel copyWith({
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
    return TaskModel(
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
}

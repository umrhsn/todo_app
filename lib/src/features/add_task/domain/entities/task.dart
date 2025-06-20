// domain/entities/task.dart
import 'package:equatable/equatable.dart';

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
}

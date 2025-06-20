import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String reminder;
  final String repeatInterval;
  final String color;
  bool isCompleted;
  bool isFavorite;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reminder,
    required this.repeatInterval,
    required this.color,
    required this.isCompleted,
    required this.isFavorite,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

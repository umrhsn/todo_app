// presentation/widgets/date_picker_widget.dart
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/core/utils/media_query_values.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime selectedDate;
  final DateTime initialSelectedDate;
  final ValueChanged<DateTime>? onDateChanged;

  const DatePickerWidget({
    super.key,
    required this.startDate,
    required this.selectedDate,
    required this.initialSelectedDate,
    this.onDateChanged,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = context.platformBrightness == Brightness.light;
    Color textColor = isLight ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
      child: DatePicker(
        widget.startDate,
        height: 80,
        width: 60,
        initialSelectedDate: widget.initialSelectedDate,
        selectionColor: isLight
            ? AppColors.primaryLight
            : AppColors.primaryDark,
        selectedTextColor: Colors.white,
        dayTextStyle: TextStyle(fontSize: 10, color: textColor),
        monthTextStyle: TextStyle(fontSize: 10, color: textColor),
        dateTextStyle: TextStyle(fontSize: 15, color: textColor),
        deactivatedColor: textColor.withOpacity(0.3),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
          widget.onDateChanged?.call(date);
        },
      ),
    );
  }
}

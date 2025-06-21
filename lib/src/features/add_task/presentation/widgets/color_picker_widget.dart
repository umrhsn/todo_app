// Enhanced color_picker_widget.dart with callback
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';

class ColorPickerWidget extends StatefulWidget {
  final int selectedColor;
  final Function(int)? onColorChanged;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    this.onColorChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  void didUpdateWidget(ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) {
      _selectedColor = widget.selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          children: List.generate(
            AppColors.tasksColorsList.length,
            (index) => _buildColorOption(index),
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(int index) {
    final isSelected = _selectedColor == index;
    final color = AppColors.tasksColorsList[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = index;
        });
        widget.onColorChanged?.call(index);
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 44.w : 36.w,
          height: isSelected ? 44.h : 36.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: isSelected
              ? Icon(Icons.check, color: Colors.white, size: 20.sp)
              : null,
        ),
      ),
    );
  }
}

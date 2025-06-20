import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/src/core/utils/app_colors.dart';
import 'package:todo_app/src/core/utils/media_query_values.dart';

class MyButtonWidget extends StatelessWidget {
  final double minWidth;
  final void Function()? onPressed;
  final String label;

  const MyButtonWidget(
      {super.key,
      this.minWidth = double.infinity,
      required this.onPressed,
      required this.label});

  @override
  Widget build(BuildContext context) {
    bool isLight = context.platformBrightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: MaterialButton(
        minWidth: minWidth,
        padding: const EdgeInsets.all(20),
        onPressed: onPressed,
        color: isLight ? AppColors.primaryLight : AppColors.primaryDark,
        textColor: Colors.white,
        elevation: 0,
        child: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  bool hasLeadingIcon;
  final IconData? leadingIcon;
  void Function()? leadingIconOnTap;
  final String title;
  bool hasActions;
  final IconData? trailingIcon;
  void Function()? trailingIconOnTap;
  PreferredSizeWidget? bottom;
  double toolbarHeight;

  AppBarWidget({
    super.key,
    required this.title,
    this.hasLeadingIcon = false,
    this.leadingIcon,
    this.leadingIconOnTap,
    this.hasActions = false,
    this.trailingIcon,
    this.trailingIconOnTap,
    this.bottom,
    this.toolbarHeight = 65,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: hasLeadingIcon
          ? InkWell(
              onTap: leadingIconOnTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: IconButton(
                  onPressed:
                      leadingIconOnTap, // Fixed: removed duplicate onPressed
                  icon: Icon(leadingIcon),
                ),
              ),
            )
          : null,
      title: Text(title),
      actions: hasActions
          ? [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: IconButton(
                  onPressed: trailingIconOnTap,
                  icon: Icon(trailingIcon),
                ),
              )
            ]
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

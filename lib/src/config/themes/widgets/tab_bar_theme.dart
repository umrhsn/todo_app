import 'package:flutter/material.dart';

class TabBarThemes {
  static TabBarThemeData tabBarTheme({required bool isLight}) {
    return TabBarThemeData(
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLight ? Colors.black : Colors.white,
            width: 3,
          ),
        ),
        // TODO: can't give a borderRadius to a non-uniform border
        // borderRadius: BorderRadius.circular(10),
      ),
      labelColor: isLight ? Colors.black : Colors.white,
      unselectedLabelColor: Colors.grey,
      indicatorSize: TabBarIndicatorSize.label,
    );
  }
}

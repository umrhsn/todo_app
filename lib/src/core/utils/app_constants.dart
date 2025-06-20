import 'package:flutter/material.dart';
import 'package:todo_app/src/features/board/presentation/views/all_tab_bar_view.dart';
import 'package:todo_app/src/features/board/presentation/views/completed_tab_bar_view.dart';
import 'package:todo_app/src/features/board/presentation/views/uncompleted_tab_bar_view.dart';
import 'package:todo_app/src/features/board/presentation/views/favorite_tab_bar_view.dart';

class AppConstants {
  static const List<Widget> boardTabs = [
    Tab(text: 'All'),
    Tab(text: 'Completed'),
    Tab(text: 'Uncompleted'),
    Tab(text: 'Favorite'),
  ];

  static const List<Widget> boardTabViewsList = [
    AllTabBarView(),
    CompletedTabBarView(),
    UncompletedTabBarView(),
    FavoriteTabBarView(),
  ];

  static List<PopupMenuEntry<String>> boardMenuItems = {
    'Add to Completed',
    'Add to Uncompleted',
    'Add to Favorites',
  }.map((String choice) {
    return PopupMenuItem<String>(
      value: choice,
      child: Text(choice),
    );
  }).toList();
}

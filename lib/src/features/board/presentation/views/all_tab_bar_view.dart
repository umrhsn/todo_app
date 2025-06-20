import 'package:flutter/material.dart';
import 'package:todo_app/src/features/board/presentation/widgets/tab_view_widget.dart';

class AllTabBarView extends StatefulWidget {
  const AllTabBarView({super.key});

  @override
  State<AllTabBarView> createState() => _AllTabBarViewState();
}

class _AllTabBarViewState extends State<AllTabBarView> {
  @override
  Widget build(BuildContext context) {
    return const TabViewWidget();
  }
}

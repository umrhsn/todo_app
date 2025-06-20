import 'package:flutter/material.dart';
import 'package:todo_app/db_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/board_item.dart';

class TabViewWidget extends StatefulWidget {
  const TabViewWidget({
    super.key,
  });

  @override
  State<TabViewWidget> createState() => _TabViewWidgetState();
}

class _TabViewWidgetState extends State<TabViewWidget> {
  late int allTasksLength;

  @override
  void initState() {
    super.initState();
    allTasksLength = DatabaseCubit.get(context).tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children:
          List.generate(allTasksLength, (index) => BoardItem(index: index)),
    );
  }
}

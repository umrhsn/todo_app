import 'package:flutter/material.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/tab_view_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteTabBarView extends StatefulWidget {
  const FavoriteTabBarView({super.key});

  @override
  State<FavoriteTabBarView> createState() => _FavoriteTabBarViewState();
}

class _FavoriteTabBarViewState extends State<FavoriteTabBarView> {
  @override
  void initState() {
    super.initState();
    // Load favorite tasks when this tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BoardCubit>().loadFavoriteTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TabViewWidget(tabType: BoardTabType.favorite);
  }
}

// presentation/screens/board_screen.dart (Fixed tab indicator)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/src/config/routes/app_routes.dart';
import 'package:todo_app/src/core/utils/app_constants.dart';
import 'package:todo_app/src/core/utils/app_strings.dart';
import 'package:todo_app/src/core/widgets/app_bar_widget.dart';
import 'package:todo_app/src/features/board/presentation/cubit/board_cubit.dart';
import 'package:todo_app/src/features/board/presentation/widgets/board_tab_content.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 BoardScreen: initState called');

    _tabController = TabController(
      length: AppConstants.boardTabs.length,
      vsync: this,
      initialIndex: 0,
    );

    _tabController.addListener(_handleTabSelection);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔧 BoardScreen: Loading initial data');
      final cubit = context.read<BoardCubit>();
      cubit.loadAllTasks(); // Start with All tab
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) return;

    final tabIndex = _tabController.index;
    debugPrint('📱 BoardScreen: Tab changed to index $tabIndex');

    final boardCubit = context.read<BoardCubit>();

    switch (tabIndex) {
      case 0:
        debugPrint('📱 BoardScreen: Loading All tasks');
        boardCubit.setCurrentTab(BoardTabType.all);
        break;
      case 1:
        debugPrint('📱 BoardScreen: Loading Completed tasks');
        boardCubit.setCurrentTab(BoardTabType.completed);
        break;
      case 2:
        debugPrint('📱 BoardScreen: Loading Uncompleted tasks');
        boardCubit.setCurrentTab(BoardTabType.uncompleted);
        break;
      case 3:
        debugPrint('📱 BoardScreen: Loading Favorite tasks');
        boardCubit.setCurrentTab(BoardTabType.favorite);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBarWidget(
      toolbarHeight: 100,
      title: AppStrings.boardScreenTitle,
      hasActions: true,
      trailingIcon: Icons.calendar_month_outlined,
      trailingIconOnTap: () =>
          Navigator.pushNamed(context, Routes.scheduleRoute),
      bottom: TabBar(
        controller: _tabController,
        tabs: AppConstants.boardTabs,
        isScrollable: true,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
        // Fixed: Reduced padding
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        indicatorSize: TabBarIndicatorSize.label, // Fixed: Use label size
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: TabBarView(
        controller: _tabController,
        children: const [
          BoardTabContent(tabType: BoardTabType.all),
          BoardTabContent(tabType: BoardTabType.completed),
          BoardTabContent(tabType: BoardTabType.uncompleted),
          BoardTabContent(tabType: BoardTabType.favorite),
        ],
      ),
    );
  }
}

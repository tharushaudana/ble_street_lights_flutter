import 'dart:developer';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomnavigator.dart';
import 'package:flutter/material.dart';

class BottomTabBarLayout extends StatefulWidget {
  const BottomTabBarLayout({
    super.key,
    required this.tabs,
    required this.children,
    this.onController,
  });

  final List<List> tabs;
  final List<Widget> children;
  final Function(TabController controller)? onController;

  @override
  State<StatefulWidget> createState() => _BottomTabBarLayoutState();
}

class _BottomTabBarLayoutState extends State<BottomTabBarLayout>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
    );

    /*tabController.addListener(() {
      log(tabController.index.toString());
    });*/

    if (widget.onController != null) {
      widget.onController!(tabController);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.children,
          ),
        ),
        BottomNavigator(
          tabs: widget.tabs,
          tabController: tabController,
          onSelectChanged: null,
        ),
      ],
    );
  }
}

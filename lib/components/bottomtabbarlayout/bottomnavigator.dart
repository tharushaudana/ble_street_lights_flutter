import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({
    super.key,
    required this.tabs,
    required this.tabController,
    required this.onSelectChanged,
  });

  final List<List> tabs;
  final TabController tabController;
  final dynamic onSelectChanged;

  @override
  State<StatefulWidget> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final double tabPadding = 15;
  final double tabHeight = 45;
  final double iconSize = 25;
  final double spaceBetweenIconAndText = 8;
  final Color unselectedColor = Colors.black87;
  final int animDurationMillis = 200;
  final textStyle = const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  List textWidths = [];
  List containerWidths = [];

  int selectedIndex = 0;

  double getTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();

    return textPainter.width;
  }

  generateData() {
    for (List label in widget.tabs) {
      textWidths.add(getTextWidth(label[0]) + spaceBetweenIconAndText + 5);
      containerWidths.add(iconSize + tabPadding * 2);
    }

    setOpenCloseOfTab(selectedIndex, true);
  }

  setOpenCloseOfTab(int index, bool open) {
    if (index >= widget.tabs.length) return;

    setState(() {
      if (open) {
        containerWidths[index] += textWidths[index];
        selectedIndex = index;
      } else {
        containerWidths[index] -= textWidths[index];
      }
    });
  }

  onTapTab(int index) {
    if (index == selectedIndex) return;
    setOpenCloseOfTab(selectedIndex, false);
    setOpenCloseOfTab(index, true);

    widget.tabController.index = index;

    if (widget.onSelectChanged != null) {
      widget.onSelectChanged(index);
    }
  }

  List<Widget> renderTabs() {
    List<Widget> widgets = [];

    for (int i = 0; i < widget.tabs.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () {
            onTapTab(i);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: animDurationMillis),
            height: tabHeight,
            width: containerWidths[i],
            padding: EdgeInsets.symmetric(
              horizontal: tabPadding,
            ),
            decoration: BoxDecoration(
              color: selectedIndex == i
                  ? (widget.tabs[i][2] as Color).withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(tabHeight / 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  widget.tabs[i][1],
                  size: iconSize,
                  color:
                      selectedIndex == i ? widget.tabs[i][2] : unselectedColor,
                ),
                selectedIndex == i
                    ? Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(left: spaceBetweenIconAndText),
                          child: Text(
                            widget.tabs[i][0],
                            style: textStyle.apply(
                              color: selectedIndex == i
                                  ? widget.tabs[i][2]
                                  : unselectedColor,
                            ),
                            overflow: TextOverflow.clip,
                            softWrap: false,
                          ),
                        ),
                      ).animate().moveX(
                        delay: (animDurationMillis / 4).ms,
                        duration: animDurationMillis.ms)
                    : Container(),
              ],
            ),
          ),
        ),
      );

      if (i < widget.tabs.length - 1) {
        widgets.add(Spacer());
      }
    }

    return widgets;
  }

  @override
  void initState() {
    generateData();

    widget.tabController.addListener(() {
      if (selectedIndex != widget.tabController.index) {
        onTapTab(widget.tabController.index);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Row(
        children: renderTabs(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CelluarBar extends StatefulWidget {
  const CelluarBar({super.key, required this.width, required this.rssi});

  final double width;
  final int rssi;

  @override
  State<StatefulWidget> createState() => _CelluarBarState();
}

class _CelluarBarState extends State<CelluarBar> {
  final double SPACE_BETWEEN_FOR_WIDTH_50 = 6;

  final List strengthColors = [
    Color.fromARGB(255, 237, 30, 36), // active bar count : 1
    Color.fromARGB(255, 242, 103, 34), // active bar count : 2
    Color.fromARGB(255, 138, 198, 64), // active bar count : 3
    Color.fromARGB(255, 22, 170, 74), // active bar count : 4
  ];

  late double height;
  late double width;
  late double widthPerBar;
  late double spaceBetween;
  late int activeBarCount = 0;
  late Color strengthColor;

  getBarHeight(int barIndex) {
    return (height / 4) * (barIndex + 1);
  }

  setActiveBarCount(int rssi) {
    if (rssi > -60) {
      activeBarCount = 4;
    } else if (rssi > -70) {
      activeBarCount = 3;
    } else if (rssi > -80) {
      activeBarCount = 2;
    } else {
      activeBarCount = 1;
    }

    strengthColor = strengthColors[activeBarCount - 1];
  }

  List<Widget> getBars(int rssi) {
    List<Widget> bars = [];

    setActiveBarCount(widget.rssi);

    for (int i = 0; i < 4; i++) {
      bars.add(
        Container(
          width: widthPerBar,
          height: getBarHeight(i),
          margin: EdgeInsets.only(right: i < 3 ? spaceBetween : 0),
          decoration: BoxDecoration(
            color: i + 1 <= activeBarCount
                ? strengthColor
                : strengthColor.withOpacity(0.2),
            borderRadius: BorderRadius.all(
              Radius.circular(widthPerBar / 2),
            ),
          ),
        ).animate().fade(duration: 300.ms, delay: (50 * (i + 1)).ms),
      );
    }

    return bars;
  }

  @override
  void initState() {
    height = widget.width;
    width = widget.width;
    spaceBetween = (SPACE_BETWEEN_FOR_WIDTH_50 / 50) * width;
    widthPerBar = (width - spaceBetween * 3) / 4;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: getBars(widget.rssi)
      ),
    );
  }
}

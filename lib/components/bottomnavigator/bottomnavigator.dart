import 'package:flutter/material.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({
    super.key,
    required this.labels,
  });

  final List<List> labels;

  @override
  State<StatefulWidget> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final double tabPadding = 10;
  final double iconSize = 15;
  final double spaceBetween = 8;
  final textStyle = const TextStyle(fontFamily: 'Nunito');

  List textWidths = [];
  List containerWidths = [];

  int selectedIndex = 0;

  double getTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    return textPainter.width;
  }

  generateData() {
    for (List label in widget.labels) {
      textWidths.add(getTextWidth(label[0]));
      containerWidths.add(iconSize + tabPadding * 2 + spaceBetween);
    }
  }

  @override
  void initState() {
    generateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Row(
        children: [
          for (int i = 0; i < widget.labels.length; i++)
            Container(
              width: containerWidths[i],
              padding:
                  EdgeInsets.symmetric(vertical: tabPadding, horizontal: 15),
              child: Icon(widget.labels[i][1]),
            ),
        ],
      ),
    );
  }
}

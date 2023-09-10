import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SimpleStepper extends StatefulWidget {
  SimpleStepper({
    super.key,
    required this.stepTitles,
    this.currentStep = 0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.activeTextColor = Colors.black,
    this.inactiveTextColor = Colors.grey,
    this.iconColor = Colors.white,
    this.lineColor = Colors.black,
    this.icon = Icons.circle,
    this.indicatorSize = 30,
    this.lineStrokeWidth = 3,
  });

  final List<List<String>> stepTitles;
  final int currentStep;
  Color activeColor;
  Color inactiveColor;
  Color activeTextColor;
  Color inactiveTextColor;
  Color iconColor;
  Color lineColor;
  final IconData icon;
  final double indicatorSize;
  final double lineStrokeWidth;

  @override
  State<StatefulWidget> createState() => _SimpleStepperState();
}

class _SimpleStepperState extends State<SimpleStepper> {
  GlobalKey keyOfStack = GlobalKey();
  GlobalKey keyOfStart = GlobalKey();
  GlobalKey keyOfEnd = GlobalKey();

  double? lineMarginLeft;
  double? lineWidth;
  bool isLineRendered = false;

  int previousStep = 0;

  Offset? _getPos(GlobalKey key, {bool global = true, Offset? point}) {
    try {
      RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      if (global) {
        return box.localToGlobal(Offset.zero);
      } else if (point != null) {
        return box.globalToLocal(point);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  _setLineRenderDetails() {
    Offset offsetOfStack = _getPos(keyOfStack)!;
    Offset start = _getPos(
      keyOfStart,
      global: false,
      point: offsetOfStack,
    )!;
    Offset end = _getPos(
      keyOfEnd,
      global: false,
      point: offsetOfStack,
    )!;

    lineMarginLeft = start.dx.abs();
    lineWidth = (end.dx - start.dx).abs();
  }

  @override
  Widget build(BuildContext context) {
    if (previousStep != widget.currentStep) {
      isLineRendered = false;
      previousStep = widget.currentStep;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isLineRendered) return;
      _setLineRenderDetails();
      setState(() {
        isLineRendered = true;
      });
    });

    return Stack(
      key: keyOfStack,
      children: [
        isLineRendered
            ? Container(
                margin: EdgeInsets.only(
                  left: lineMarginLeft! + widget.indicatorSize / 2,
                  top: widget.indicatorSize / 2 - widget.lineStrokeWidth / 2,
                ),
                width: lineWidth!,
                height: widget.lineStrokeWidth,
                color: widget.lineColor,
              )
            : Container(),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < widget.stepTitles.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      key: i == 0
                          ? keyOfStart
                          : i == widget.stepTitles.length - 1
                              ? keyOfEnd
                              : null,
                      width: widget.indicatorSize,
                      height: widget.indicatorSize,
                      padding: i != widget.currentStep
                          ? const EdgeInsets.all(3)
                          : null,
                      child: Container(
                        //width: i == widget.currentStep ? widget.indicatorSize : widget.indicatorSize * 0.75,
                        //height: i == widget.currentStep ? widget.indicatorSize : widget.indicatorSize * 0.75,
                        decoration: BoxDecoration(
                          color: widget.currentStep < i
                              ? widget.inactiveColor
                              : widget.activeColor,
                          shape: BoxShape.circle,
                          boxShadow: i == widget.currentStep
                              ? [
                                  BoxShadow(
                                    color: widget.activeColor.withOpacity(0.8),
                                    blurRadius: 4,
                                  )
                                ]
                              : null,
                        ),
                        child: i <= widget.currentStep
                            ? Center(
                                child: Icon(
                                  widget.icon,
                                  color: widget.iconColor,
                                  size: i == widget.currentStep
                                      ? widget.indicatorSize * 0.4
                                      : widget.indicatorSize * 0.4,
                                ),
                              )
                            : Container(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.stepTitles[i][i == widget.currentStep ? 1 : 0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: i == widget.currentStep ? widget.activeTextColor : widget.inactiveColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

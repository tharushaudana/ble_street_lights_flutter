import 'package:flutter/material.dart';
import 'dart:math' as math;

class BadgeSwitch extends StatefulWidget {
  const BadgeSwitch({
    super.key,
    required this.child1,
    required this.child2,
    this.disabled = false,
    this.initialSwitchedChild = 1,
    required this.onSwitched,
  });

  final Widget child1;
  final Widget child2;
  final bool disabled;
  final int initialSwitchedChild;
  final Function(int childNo) onSwitched;

  @override
  State<StatefulWidget> createState() => _BadgeSwitchState();
}

class _BadgeSwitchState extends State<BadgeSwitch> with SingleTickerProviderStateMixin {
  late int switchedChild;

  late List _childOrder;
  bool _changeOrder = false;

  double _percentage = 0;
  bool _animRunning = false;

  late AnimationController _animController;
  late Animation<double> _animation;

  switchNow(int to) {
    if (switchedChild == to) return;

    _animRunning = true;

    switchedChild = to;

    widget.onSwitched(to);

    _animController.reset();
    _animController.forward();
  }

  @override
  void initState() {
    switchedChild = widget.initialSwitchedChild;
    
    _childOrder = [
      widget.child1,
      widget.child2,
    ];

    if (switchedChild != 1) _childOrder = _childOrder.reversed.toList();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCirc,
      ),
    )..addListener(() {
        if (_animation.value == 1)  {
          _animRunning = false;
          _changeOrder = true;
          _percentage = 0;
          _animController.reset();
        } else {
          _percentage = _animation.value;
        }
        setState(() {});
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_changeOrder) {
      _childOrder = _childOrder.reversed.toList();
      _changeOrder = false;
    }

    return GestureDetector(
      onTap: () {
        if (widget.disabled || _animRunning) return;
        switchNow(switchedChild == 1 ? 2 : 1);
      },
      child: Stack(
        children: [
          Opacity(
            opacity: _percentage < 0.3 ? 0 : (_percentage - 0.3) / 0.7,
            child: Transform.translate(
              offset: Offset(-30 * (1 - _percentage), 0),
              child: _childOrder[1],
            ),
          ),
          Opacity(
            opacity: widget.disabled ? 0.5 : 1 - _percentage,
            child: Transform.translate(
              offset: Offset(10 * (_percentage), 0),
              child: _childOrder[0],
              //child: widget.child1,
            ),
          ),
          /*Transform.scale(
            scale: 0.5,
            child: widget.child2,
          ),*/
        ],
      ),
    );
  }
}

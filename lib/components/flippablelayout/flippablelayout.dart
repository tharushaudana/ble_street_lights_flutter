import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

class FlippableLayout extends StatefulWidget {
  const FlippableLayout({
    super.key,
    required this.front,
    required this.back,
    required this.duration,
    required this.flipped,
  });

  final Widget front;
  final Widget back;
  final Duration duration;
  final bool flipped;

  @override
  State<StatefulWidget> createState() => _FlippableLayoutState();
}

class _FlippableLayoutState extends State<FlippableLayout> {
  Widget flipTransitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: math.pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(!this.widget.flipped) != widget!.key);

        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;

        tilt *= isUnder ? -1.0 : 1.0;

        final value = isUnder
            ? math.min(rotateAnim.value, math.pi / 2)
            : rotateAnim.value;

        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(1, 3, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: flipTransitionBuilder,
      switchInCurve: Curves.easeInOutCirc,
      switchOutCurve: Curves.easeInOutCirc.flipped,
      child: !widget.flipped ? widget.front : widget.back,
    );
  }
}

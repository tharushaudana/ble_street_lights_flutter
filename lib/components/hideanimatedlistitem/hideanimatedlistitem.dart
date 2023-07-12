import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HideAnimatedListItem extends StatefulWidget {
  const HideAnimatedListItem(
      {super.key, required this.child, required this.hidden});

  final Widget child;
  final bool hidden;

  @override
  State<StatefulWidget> createState() => _HideAnimatedListItemState();
}

class _HideAnimatedListItemState extends State<HideAnimatedListItem> {
  late AnimationController animControllerHide;

  GlobalKey childKey = GlobalKey();

  double childHeight = 0;

  @override
  void initState() {
    super.initState();
  }

  checkHidden() {
    if (widget.hidden) animControllerHide.forward();
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final context = childKey.currentContext;
        if (context == null) return;
        childHeight = context.size!.height;
      },
    );

    checkHidden();

    return Stack(
      children: [
        Container(
          key: childKey,
          child: widget.child,
        )
            .animate(
              autoPlay: false,
              onInit: (controller) {
                animControllerHide = controller;
              },
            )
            .fadeOut(duration: 300.ms)
            .swap(
          builder: (context, child) {
            return Container().animate().custom(
              begin: childHeight,
              end: 0,
              curve: Curves.easeInOutCirc,
              duration: 200.ms,
              builder: (context, value, child) {
                return Container(
                  height: value,
                  color: Colors.transparent,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

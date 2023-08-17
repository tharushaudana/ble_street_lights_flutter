import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularValueIndicator extends StatefulWidget {
  const CircularValueIndicator({
    super.key,
    required this.size,
    required this.value,
    this.bgColor = Colors.white,
    this.highColor = Colors.amber,
    this.lowColor = Colors.blue,
    this.trackWidth = 4,
  });

  final double size;
  final double value;
  final Color bgColor;
  final Color highColor;
  final Color lowColor;
  final double trackWidth;

  @override
  State<StatefulWidget> createState() => _CircularValueIndicatorState();
}

class _CircularValueIndicatorState extends State<CircularValueIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  bool _isAnimRunning = false;

  double _currentSettedValue = 0;
  double _value = 0;

  _runValueFillAnim() {
    _isAnimRunning = true;

    _animation = Tween(begin: _value, end: widget.value).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCirc,
      ),
    )..addListener(() {
        _value = _animation.value;
        setState(() {});
      });

    _animController.reset();
    _animController.forward();
  }

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSettedValue != widget.value || (!_isAnimRunning && _value != widget.value)) {
      _currentSettedValue = widget.value;
      _runValueFillAnim();
    } else if (_value == widget.value) {
      _isAnimRunning = false;
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: CircularValueIndicatorPainter(
        value: _value,
        bgColor: widget.bgColor,
        highColor: widget.highColor,
        lowColor: widget.lowColor,
        trackWidth: widget.trackWidth,
      ),
    );
  }
}

class CircularValueIndicatorPainter extends CustomPainter {
  const CircularValueIndicatorPainter({
    required this.value,
    required this.bgColor,
    required this.highColor,
    required this.lowColor,
    required this.trackWidth,
  });

  final double value;
  final Color bgColor;
  final Color highColor;
  final Color lowColor;
  final double trackWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rectGradient = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2);
    Rect rectInner = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - trackWidth);
    Rect rectHider = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.width / 2 + size.width / 2 - trackWidth) / 2);

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: GradientRotation(math.pi / 2),
      tileMode: TileMode.decal,
      colors: [lowColor, highColor, highColor, lowColor],
      /*stops: const [
        0,
        1/12,
        0.75 + 1/12,
      ],*/
    );

    final Paint paintGradientRect = Paint()
      ..shader = gradient.createShader(rectGradient)
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final Paint paintInnerRect = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final Paint paintHiderRect = Paint()
      ..color = bgColor
      ..strokeWidth = trackWidth + 1
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rectGradient, 0, math.pi * 2, true, paintGradientRect);
    canvas.drawArc(rectInner, 0, math.pi * 2, true, paintInnerRect);
    canvas.drawArc(rectHider, 0, -((100 - value) / 100 * math.pi * 2), true,
        paintHiderRect);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

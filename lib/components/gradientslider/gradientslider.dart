import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_animate/flutter_animate.dart';

class GradientSlider extends StatefulWidget {
  const GradientSlider({
    super.key,
    required this.min,
    required this.max,
    this.trackHeight = 30,
    this.tricksCount = 20,
    this.tricksHeight = 25,
    this.thumbSize = 40,
    this.thumbBorderWidth = 1,
    this.colors = const [Color(0xff413be7), Color(0xffffd4cb)],
    this.tricksColor = Colors.grey,
    this.thumbBgColor = Colors.white,
    this.thumbBorderColor = const Color(0xff413be7),
    this.thumbLabelTextStyle = const TextStyle(
      color: Color(0xff413be7),
      fontWeight: FontWeight.bold,
    ),
  });

  final double min;
  final double max;
  final double trackHeight;
  final int tricksCount;
  final double tricksHeight;
  final double thumbSize;
  final double thumbBorderWidth;
  final List<Color> colors;
  final Color tricksColor;
  final Color thumbBgColor;
  final Color thumbBorderColor;
  final TextStyle thumbLabelTextStyle;

  @override
  State<StatefulWidget> createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    double _value = 50;

    final double thumbPercent = _value / (widget.max - widget.min);

    return CustomPaint(
      size: Size(width, 200),
      painter: GradientSliderPainer(
        trackHeight: widget.trackHeight,
        tricksCount: widget.tricksCount,
        tricksHeight: widget.tricksHeight,
        thumbSize: widget.thumbSize,
        thumbBorderWidth: widget.thumbBorderWidth,
        colors: widget.colors,
        tricksColor: widget.tricksColor,
        thumbBgColor: widget.thumbBgColor,
        thumbBorderColor: widget.thumbBorderColor,
        thumbPercent: thumbPercent,
        thumbLabelTextStyle: widget.thumbLabelTextStyle,
        thumbLabel: "$_value%",
      ),
    );
  }
}

class GradientSliderPainer extends CustomPainter {
  GradientSliderPainer({
    required this.trackHeight,
    required this.tricksCount,
    required this.tricksHeight,
    required this.thumbSize,
    required this.thumbBorderWidth,
    required this.colors,
    required this.tricksColor,
    required this.thumbBgColor,
    required this.thumbBorderColor,
    required this.thumbPercent,
    required this.thumbLabel,
    required this.thumbLabelTextStyle,
  });

  final double trackHeight;
  final double tricksHeight;
  final int tricksCount;
  final double thumbSize;
  final double thumbBorderWidth;
  final List<Color> colors;
  final Color tricksColor;
  final Color thumbBgColor;
  final Color thumbBorderColor;
  final TextStyle thumbLabelTextStyle;

  final double thumbPercent;
  final String thumbLabel;

  late Canvas canvas;
  late Size size;

  double thumbMargin = 0;
  double thumbDx = 0;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;

    thumbMargin = thumbSize / 2;
    thumbDx = thumbMargin + thumbPercent * (size.width - thumbMargin * 2);

    _paintTrack();
    _paintTricks();
    _paintMainTrick();
    _paintMainTrickLabel();
    _painThumb();
  }

  _painThumb() {
    Offset c = Offset(thumbDx, size.height - trackHeight / 2);

    Rect rect = Rect.fromCenter(
      center: c,
      width: thumbSize,
      height: thumbSize,
    );

    Paint paint1 = Paint()
      ..style = PaintingStyle.fill
      ..color = thumbBgColor;

    Paint paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thumbBorderWidth
      ..color = thumbBorderColor;

    //### draw Shadow
    canvas.drawCircle(
      c.copyWith(dy: size.height - trackHeight / 2 + 5),
      thumbSize / 2 + 5,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    //### draw Circles
    canvas.drawArc(rect, 0, math.pi * 2, true, paint1);
    canvas.drawCircle(c, thumbSize / 2, paint2);
  }

  _paintMainTrickLabel() {
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);

    painter.text = TextSpan(
      text: thumbLabel,
      style: thumbLabelTextStyle,
    );

    painter.layout();

    final double dy =
        size.height - trackHeight - tricksHeight - 8 - painter.height;

    painter.paint(
      canvas,
      Offset(thumbDx - painter.width / 2, dy),
    );
  }

  _paintMainTrick() {
    final double dy = size.height - trackHeight;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = thumbBorderColor;

    canvas.drawLine(
        Offset(thumbDx, dy), Offset(thumbDx, dy - tricksHeight - 5), paint);
  }

  _paintTricks() {
    double step = (size.width - thumbMargin * 2) / tricksCount;

    final double dy = size.height - trackHeight;
    double dx = thumbMargin;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = tricksColor;

    for (int i = 0; i < tricksCount + 1; i++) {
      canvas.drawLine(Offset(dx, dy), Offset(dx, dy - tricksHeight), paint);
      dx += step;
    }
  }

  _paintTrack() {
    Rect rect = Rect.fromPoints(
        Offset(0, size.height - trackHeight), Offset(size.width, size.height));

    LinearGradient gradient = LinearGradient(colors: colors);

    Paint paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

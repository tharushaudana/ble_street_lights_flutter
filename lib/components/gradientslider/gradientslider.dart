import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_animate/flutter_animate.dart';

class GradientSlider extends StatefulWidget {
  const GradientSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    this.intLabel = false,
    this.height = 100,
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
    required this.onChange,
  });

  final double min;
  final double max;
  final double value;
  final bool intLabel;
  final double height;
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
  final Function(double value) onChange;

  @override
  State<StatefulWidget> createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider> {
  late GradientSliderPainerListener sliderPainerListener;

  bool isThumbDetected = false;

  onPanStart(DragStartDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    sliderPainerListener.notifyPanStart(localPos);
  }

  onPanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    sliderPainerListener.notifyPanUpdate(localPos);
  }

  @override
  void initState() {
    sliderPainerListener = GradientSliderPainerListener(
      onThumbDetected: () {
        isThumbDetected = true;
      },
      onChangePercent: (percent) {
        if (!isThumbDetected) return;
        double v = (widget.max - widget.min) * percent;
        v = double.parse(v.toStringAsFixed(2));
        widget.onChange(v);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final double thumbPercent = widget.value / (widget.max - widget.min);

    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: (details) {
        isThumbDetected = false;
      },
      child: CustomPaint(
        size: Size(width, widget.height),
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
          thumbLabel: widget.intLabel ? "${widget.value.toInt()}%" : "${widget.value}%",
          listener: sliderPainerListener,
        ),
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
    required this.listener,
  }) {
    _initListener();
  }

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
  //---
  final double thumbPercent;
  final String thumbLabel;
  final GradientSliderPainerListener listener;

  late Canvas canvas;
  late Size size;

  double thumbMargin = 0;
  double thumbDx = 0;

  _initListener() {
    listener.init(
      onPanStart: (p) {
        if (_isPointOnCircle(p, _thumbCenter(), thumbSize / 2)) {
          listener.onThumbDetected();
        }
      },
      onPanUpdate: (p) {
        double percent = (p.dx - thumbMargin) / (size.width - thumbMargin * 2);

        if (percent < 0) percent = 0;
        if (percent > 1) percent = 1;

        listener.onChangePercent(percent);
      },
    );
  }

  bool _isPointOnCircle(Offset point, Offset c, double r) {
    return (math.pow((point.dx - c.dx), 2) + math.pow((point.dy - c.dy), 2) - math.pow(r, 2)) < 0;
  }

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
    Offset c = _thumbCenter();

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

  Offset _thumbCenter() {
    return Offset(thumbDx, size.height - trackHeight / 2);
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

class GradientSliderPainerListener {
  GradientSliderPainerListener({
    required this.onThumbDetected,
    required this.onChangePercent,
  });

  final VoidCallback onThumbDetected;
  final Function(double percent) onChangePercent;

  Function(Offset p)? onPanStart;
  Function(Offset p)? onPanUpdate;

  notifyPanStart(Offset p) {
    if (onPanStart == null) return;
    onPanStart!(p);
  }

  notifyPanUpdate(Offset p) {
    if (onPanUpdate == null) return;
    onPanUpdate!(p);
  }

  init({
    Function(Offset p)? onPanStart,
    Function(Offset p)? onPanUpdate,
  }) {
    this.onPanStart = onPanStart;
    this.onPanUpdate = onPanUpdate;
  }
}

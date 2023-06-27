import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

int oldDeviceListSize = 0;

class RadarPainter extends CustomPainter {
  final Color color;
  final Color tcolor;
  final double sweepAngle;
  final double scaleSize;
  final ui.Image deviceIcon;
  final List devices;
  final maxRssi;
  final bool isScanRunning;
  final scaleEffectTicker;
  final onTapCallback;
  final onBluetoothIconClicked;
  final onDeviceClicked;

  final double middleCircleRadius = 25;
  final double bspace = 25 * 3; // space between middle circle and first ring
  final double deviceIconSize = 30;

  final refreshIcon = Icons.refresh;
  final btIcon = Icons.bluetooth;

  late Canvas _canvas;
  late Size _size;
  late Offset _center;

  RadarPainter({
    this.color = Colors.blue,
    this.tcolor = Colors.white,
    this.sweepAngle = 0,
    this.scaleSize = 0,
    required this.deviceIcon,
    required this.devices,
    this.maxRssi,
    this.isScanRunning = false,
    required this.scaleEffectTicker,
    required this.onTapCallback,
    required this.onBluetoothIconClicked,
    required this.onDeviceClicked,
  }) {
    if (onTapCallback != null) onTapCallback(onCanvasTap);
  }

  onCanvasTap(Offset pos) {
    //### check for Bluetooth Icon Click
    if (isPointOnCircle(pos, _center, middleCircleRadius)) {
      onBluetoothIconClicked();
    }
    //### check for Device Clicks
    else {
      iterateDevices((List device, Offset center, int i) {
        if (isPointOnCircle(pos, center, deviceIconSize / 2)) {
          onDeviceClicked(device);
          return false; // break the loop
        } else {
          return true; // continue the loop
        }
      });
    }
  }

  bool isPointOnCircle(Offset pos, Offset center, double radius) {
    return math.pow(pos.dx - center.dx, 2) +
            math.pow(pos.dy - center.dy, 2) -
            math.pow(radius, 2) <
        0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;
    _center = Offset(size.width / 2, size.height - middleCircleRadius);

    //################ Draw Rings...

    drawRing(1);
    drawRing(1.9);
    drawRing(3);

    //drawBluredArc();

    //################ Draw Scanner

    Paint paintScanner = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height),
        size.height * 1.5,
        [
          color.withAlpha(150),
          color.withAlpha(20),
        ],
      );

    canvas.drawArc(
      Rect.fromCenter(
        center: _center,
        width: size.width - middleCircleRadius * 2 + 3,
        height: size.width - middleCircleRadius * 2 + 3,
      ),
      //math.pi * 1.25,
      //sweepAngle,
      sweepAngle,
      math.pi / 2.5,
      true,
      paintScanner,
    );

    //################ Draw Shadow of middle Circle

    canvas.drawCircle(
      _center,
      middleCircleRadius,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    //################ Draw Middle Circle

    canvas.drawCircle(
      _center,
      middleCircleRadius,
      Paint()..color = Colors.white,
    );

    //################ Draw Middle Icon

    drawMiddleIcon(isScanRunning ? btIcon : refreshIcon);

    //################ Draw devices

    drawDevices();
  }

  drawDevices() {
    if (devices.isEmpty) return;

    iterateDevices((List device, Offset pos, int i) {
      drawDevice(pos, device[2] == maxRssi, i == devices.length - 1);
      return true;
    });

    if (oldDeviceListSize != devices.length) {
      scaleEffectTicker();
      oldDeviceListSize = devices.length;
    }
  }

  drawDevice(Offset center, bool fullOpacity, bool scaleEffect) {
    Paint paint = Paint()
      ..color = Color.fromARGB(fullOpacity ? 255 : 150, 255, 255, 255);

    final srcRect = Rect.fromLTRB(
      0,
      0,
      deviceIcon.width.toDouble(),
      deviceIcon.height.toDouble(),
    );

    final dstRect = Rect.fromCenter(
      center: center,
      width: scaleEffect ? scaleSize : deviceIconSize,
      height: scaleEffect ? scaleSize : deviceIconSize,
    );

    _canvas.drawImageRect(deviceIcon, srcRect, dstRect, paint);
  }

  drawRing(double i) {
    final double rectsize = getRingRadius(i) * 2;

    _canvas.drawArc(
      Rect.fromCenter(
        center: _center,
        width: rectsize,
        height: rectsize,
      ),
      math.pi + (math.pi - math.pi / 1.1) / 2,
      math.pi / 1.1,
      false,
      Paint()
        ..color = color.withOpacity(0.2 * i)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke,
    );

    _canvas.drawOval(
      Rect.fromCenter(
        center:
            Offset(_size.width / 2, _size.height - middleCircleRadius + 2.5),
        width: rectsize,
        height: rectsize + 2,
      ),
      Paint()
        ..color = tcolor
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke,
    );
  }

  drawMiddleIcon(IconData icon) {
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);

    painter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style:
          TextStyle(fontSize: 30, fontFamily: btIcon.fontFamily, color: color),
    );

    painter.layout();

    painter.paint(
      _canvas,
      Offset(_size.width / 2 - 14.5, _size.height - middleCircleRadius - 14.5),
    );
  }

  drawBluredArc() {
    Paint paint = Paint()..style = PaintingStyle.fill;

    final gradient = ui.Gradient.sweep(
      _center,
      [Colors.transparent, tcolor],
      [0.1, 1],
      TileMode.clamp,
    );

    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0);
    paint.shader = gradient;

    _canvas.drawArc(
      Rect.fromCenter(
        center: _center,
        width: _size.width,
        height: _size.width,
      ),
      math.pi * 1.25,
      math.pi / 2.5,
      true,
      paint,
    );
  }

  iterateDevices(dynamic cb) {
    final radius = getRingRadius(3);

    double angle = 0;

    for (int i = 0; i < devices.length; i++) {
      double dx;
      double dy;

      dy = _size.height - (radius * math.cos(angle));

      if (i % 2 == 0) {
        dx = _size.width / 2 + (radius * math.sin(angle));
      } else {
        dx = _size.width / 2 - (radius * math.sin(angle));
      }

      if (cb(devices[i], Offset(dx, dy), i) == false) break;

      if (i % 2 == 0) angle += math.pi / 6;
    }
  }

  double getRingRadius(double i) {
    return (bspace + ((_size.width - bspace) / 3) * i) / 2 - middleCircleRadius;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
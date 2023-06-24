import 'dart:developer';
import 'package:ble_street_lights/components/radar/radarpainter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class Radar extends StatefulWidget {
  final double diameter;
  final Color color;
  final Color tcolor;
  final ui.Image deviceIcon;
  final dynamic getController;
  final dynamic onDeviceClicked;
  final dynamic onRescanClicked;

  const Radar({
    super.key,
    this.diameter = 200,
    this.color = Colors.blue,
    this.tcolor = Colors.grey,
    required this.deviceIcon,
    this.getController,
    this.onDeviceClicked,
    this.onRescanClicked,
  });

  @override
  State<StatefulWidget> createState() => _RadarState();
}

class _RadarState extends State<Radar> with TickerProviderStateMixin {
  late AnimationController _controllerScan;
  late AnimationController _controllerScale;
  late Animation<double> _animationScan;
  late Animation<double> _animationScale;

  final double startAngle = math.pi * 1.30 - math.pi / 3;
  final double endAngle = math.pi * 1.30 + math.pi / 3;

  final double startSize = 0;
  final double endSize = 30;

  double sweepAngle = 0;
  double scaleSize = 0;

  late RadarPainter radarPainter;
  late RadarController controller;

  List devices = [];
  int maxRssi = 0;
  bool isScanRunning = false;

  dynamic onCanvasTap;

  @override
  void initState() {
    super.initState();

    sweepAngle = startAngle;

    controller = RadarController(
      onNewDevice: onNewDevice,
      onStartScan: onStartScan,
      onStopScan: onStopScan,
    );

    if (widget.getController != null) widget.getController(controller);

    initAnimations();
  }

  void initAnimations() {
    _controllerScan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controllerScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animationScan = Tween(begin: startAngle, end: endAngle).animate(
      CurvedAnimation(
        parent: _controllerScan,
        curve: Curves.easeInOutCubic,
      ),
    )..addListener(() {
        setState(() {
          sweepAngle = _animationScan.value;
        });
      });

    _animationScale = Tween(begin: startSize, end: endSize).animate(
      CurvedAnimation(
        parent: _controllerScale,
        curve: Curves.easeInOutCubic,
      ),
    )..addListener(() {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            setState(() {
              scaleSize = _animationScale.value;
            });
          },
        );
      });
  }

  onNewDevice(String name, String address, int rssi) {
    scaleSize = 0;

    setState(() {
      devices.add([name, address, rssi]);
      devices.sort((a, b) => b[2].compareTo(a[2]));
      if (rssi > maxRssi) maxRssi = rssi;
    });
  }

  onStartScan() {
    setState(() {
      devices.clear();
      sweepAngle = startAngle;
      isScanRunning = true;
    });

    _controllerScan.reset();
    _controllerScan.repeat(reverse: true);
  }

  onStopScan() {
    setState(() {
      sweepAngle = startAngle;
      isScanRunning = false;
    });

    _controllerScan.stop();
  }

  scaleEffectTicker() {
    _controllerScale.reset();
    _controllerScale.forward();
  }

  onTapDown(TapDownDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    onCanvasTap(localPos);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      child: CustomPaint(
        painter: RadarPainter(
          tcolor: widget.tcolor,
          sweepAngle: sweepAngle,
          scaleSize: scaleSize,
          deviceIcon: widget.deviceIcon,
          devices: devices,
          maxRssi: maxRssi,
          isScanRunning: isScanRunning,
          scaleEffectTicker: scaleEffectTicker,
          onTapCallback: (cb) {
            onCanvasTap = cb;
          },
          onBluetoothIconClicked: () {
            if (!isScanRunning) widget.onRescanClicked();
          },
          onDeviceClicked: (List device) {
            widget.onDeviceClicked(device);
          },
        ),
        size: Size(widget.diameter, widget.diameter / 2),
      ),
    );
  }

  @override
  void dispose() {
    _controllerScan.dispose();
    _controllerScale.dispose();
    super.dispose();
  }
}

class RadarController {
  RadarController({
    required this.onNewDevice,
    required this.onStartScan,
    required this.onStopScan,
  });

  //### incoming
  final onNewDevice;
  final onStartScan;
  final onStopScan;

  bool isAlreadyStarted = false;

  addDevice(String name, String address, int rssi) {
    onNewDevice(name, address, rssi);
  }

  startScan() {
    if (isAlreadyStarted) return;
    onStartScan();
    isAlreadyStarted = true;
  }

  stopScan() {
    if (!isAlreadyStarted) return;
    onStopScan();
    isAlreadyStarted = false;
  }
}

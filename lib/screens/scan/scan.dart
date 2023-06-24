import 'dart:developer';
import 'dart:async';
import 'package:ble_street_lights/components/radar/radar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen();

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Future<ui.Image> loadDeviceIconImage() async {
    final completer = Completer<ui.Image>();
    final imageProvider = AssetImage("assets/images/device_icon.png");
    final config = ImageConfiguration(size: Size(3, 3));

    final stream = imageProvider.resolve(config);
    final listener = ImageStreamListener((imageInfo, synchronousCall) {
      final image = imageInfo.image;
      completer.complete(image);
    });

    stream.addListener(listener);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan"),
      ),
      body: FutureBuilder(
        future: loadDeviceIconImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          } else if (snapshot.connectionState == ConnectionState.done) {
            ui.Image image = snapshot.data as ui.Image;
            return ScannerLoadedLayout(deviceIcon: image);
          }

          return Text("error");
        },
      ),
    );
  }
}

class ScannerLoadedLayout extends StatefulWidget {
  const ScannerLoadedLayout({required this.deviceIcon});

  final ui.Image deviceIcon;

  @override
  State<StatefulWidget> createState() => _ScannerLoadedLayoutState();
}

class _ScannerLoadedLayoutState extends State<ScannerLoadedLayout> {
  late RadarController radarController;

  List devices = [
    ["name1", "abc", 90],
    ["name2", "edf", 95],
    ["name3", "hjg", 91]
  ];

  int i = 0;

  bool b = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
          ),
          Radar(
            diameter: 400,
            color: Colors.blue,
            tcolor: Colors.grey.shade50,
            deviceIcon: widget.deviceIcon,
            getController: (RadarController controller) {
              radarController = controller;
            },
            onRescanClicked: () {
              radarController.startScan();
              setState(() {
                b = true;
              });
            },
            onDeviceClicked: (List device) {
              log(device[0] + " dd");
            },
          ),
          SizedBox(
            height: 50,
          ),
          Text("data"),
          TextButton(
            onPressed: () {
              if (i > 2) return;

              List d = devices[i++];

              radarController.addDevice(d[0], d[1], d[2]);
            },
            child: Text("Add Device"),
          ),
          TextButton(
            onPressed: () {
              if (!b)
                radarController.startScan();
              else
                radarController.stopScan();
              setState(() {
                b = !b;
              });
            },
            child: Text(!b ? "Start Scan" : "Stop Scan"),
          ),
        ],
      ),
    );
  }
}

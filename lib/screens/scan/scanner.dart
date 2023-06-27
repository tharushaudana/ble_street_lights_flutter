import 'dart:developer';
import 'package:ble_street_lights/components/radar/radar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key, required this.deviceIcon});

  final ui.Image deviceIcon;

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late RadarController radarController;
  
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  bool isScanning = false;

  List<BluetoothDevice> devices = [];

  scanForDevices() async {
    flutterBlue.startScan(timeout: Duration(seconds: 5)).then((value) {
      radarController.stopScan();
      setState(() {
        isScanning = false;
      });
    });

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        addDevice(r.device, r.rssi);
      }
    });

    radarController.startScan();

    setState(() {
      devices.clear();
      isScanning = true;
    });
  }

  addDevice(BluetoothDevice device, int rssi) {
    if (devices.contains(device)) return;
    devices.add(device);
    radarController.addDevice(device.name, device.id.toString(), rssi);
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scanForDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radar(
          diameter: 400,
          color: Colors.blue,
          tcolor: Colors.grey.shade50,
          deviceIcon: widget.deviceIcon,
          getController: (RadarController controller) {
            radarController = controller;
          },
          onRescanClicked: () {
            scanForDevices();
          },
          onDeviceClicked: (List device) {
            log(device[0] + " dd");
          },
        ).animate().fade(duration: 300.ms),
      ],
    );
  }
}

import 'dart:developer';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:ble_street_lights/components/radar/radar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Scanner extends StatefulWidget {
  const Scanner(
      {super.key, required this.deviceIcon, required this.onAddDeviceClicked});

  final ui.Image deviceIcon;
  final onAddDeviceClicked;

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

  closeMain() {
    Navigator.pop(context);
  }

  openDialogDeviceDetails(List device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          title: Row(
            children: [
              const Image(
                image: AssetImage("assets/images/device_icon.png"),
                width: 42,
                height: 42,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device[0],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    device[1],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 15),
              Stack(
                children: [
                  Container(
                    width: 33,
                    height: 15,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${device[2]} dBm",
                      style: const TextStyle(
                        fontSize: 7,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 38,
                    alignment: Alignment.centerRight,
                    child: CelluarBar(
                      width: 27,
                      rssi: device[2],
                    ),
                  ),
                ],
              )
            ],
          ),
          content: Container(
            child: TextButton(
              onPressed: () {
                flutterBlue.stopScan().then((value) {
                  widget.onAddDeviceClicked(device);
                  closeMain();
                  Navigator.pop(context);
                });
              },
              child: Row(
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 7),
                  const Text("ADD"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scanForDevices();
    });
  }

  @override
  void dispose() {
    if (flutterBlue.isScanningNow) {
      flutterBlue.stopScan();
    }
    super.dispose();
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
            openDialogDeviceDetails(device);
          },
        ).animate().fade(duration: 300.ms),
      ],
    );
  }
}

import 'dart:developer';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:ble_street_lights/components/radar/radar.dart';
import 'package:ble_street_lights/helpers/bluetooth.dart';
import 'package:ble_street_lights/screens/scan/dialogs/devicedetailsdialog.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    required this.deviceIcon,
    required this.onAddDeviceClicked,
  });

  final ui.Image deviceIcon;
  final dynamic onAddDeviceClicked;

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late RadarController radarController;

  BluetoothHelper bluetooth = BluetoothHelper();

  List<BluetoothDevice> devices = [];

  scanForDevices() {
    bluetooth.startScan(
      started: () {
        radarController.startScan();

        setState(() {
          devices.clear();
        });
      },
      stopped: () {
        radarController.stopScan();
      },
    );
  }

  listenForBluetooth() {
    /*bluetooth.listenForScanStateChanges(
      started: () {
        radarController.startScan();
        setState(() {
          devices.clear();
        });
      },
      stopped: () {
        radarController.stopScan();
      },
    );*/

    bluetooth.listenForScanResults((List<ScanResult> results) {
      for (ScanResult r in results) {
        addDevice(r.device, r.rssi);
      }
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
        return DeviceDetailsDialog(
          device: device,
          onAddClicked: () {
            bluetooth.stopScan(() {
              widget.onAddDeviceClicked(device);
              closeMain();
              Navigator.pop(context);
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    bluetooth.setStateClass(this);

    listenForBluetooth();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scanForDevices();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
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

  @override
  void dispose() {
    bluetooth.dispose();
    super.dispose();
  }
}

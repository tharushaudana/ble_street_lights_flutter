import 'dart:async';
import 'package:ble_street_lights/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothHelper extends Helper {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  bool isEnabled = false;
  bool isScanning = false;

  StreamSubscription? serviceStateChangeListener;
  StreamSubscription? scanStateChangeListener;
  StreamSubscription? scanResultsListener;

  Future<bool> checkIsEnabled() async {
    isEnabled = await flutterBlue.isOn;
    return isEnabled;
  }

  void listenForServiceStatusChanges(VoidCallback? cb) {
    serviceStateChangeListener = flutterBlue.state.listen((state) {
      setState(() {
        isEnabled = state == BluetoothState.on;
      });

      if (cb != null) cb();
    });
  }

  void listenForScanStateChanges({
    required VoidCallback started,
    required VoidCallback stopped,
  }) {
    scanStateChangeListener = flutterBlue.isScanning.listen(
      (bool scanningNow) {
        if (scanningNow) {
          started();
          setState(() {
            isScanning = true;
          });
        } else {
          stopped();
          setState(() {
            isScanning = false;
          });
        }
      },
    );
  }

  Future<void> startScan({
    VoidCallback? started,
    VoidCallback? stopped,
  }) async {
    if (flutterBlue.isScanningNow) {
      if (started != null) started();
      return;
    }

    try {
      if (started != null) started();

      setState(() {
        isScanning = true;
      });

      await flutterBlue.startScan(timeout: Duration(seconds: 5)).then((value) {
        if (stopped != null) stopped();

        setState(() {
          isScanning = false;
        });
      });
    } catch (e) {}
  }

  void stopScan(VoidCallback cb) {
    try {
      flutterBlue.stopScan().then((value) {
        cb();
      });
    } catch (e) {}
  }

  void listenForScanResults(cb) {
    scanResultsListener = flutterBlue.state.listen((state) {
      flutterBlue.scanResults.listen((results) {
        cb(results);
      });
    });
  }

  @override
  void dispose() {
    if (serviceStateChangeListener != null) {
      serviceStateChangeListener!.cancel();
    }

    if (scanStateChangeListener != null) {
      scanStateChangeListener!.cancel();
    }

    if (scanResultsListener != null) {
      scanResultsListener!.cancel();
    }

    if (flutterBlue.isScanningNow) {
      flutterBlue.stopScan();
    }

    super.dispose();
  }
}

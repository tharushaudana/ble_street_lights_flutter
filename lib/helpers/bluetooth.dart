import 'dart:async';
import 'package:ble_street_lights/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothHelper extends Helper {
  bool isEnabled = false;
  bool isScanning = false;

  StreamSubscription? serviceStateChangeListener;
  StreamSubscription? scanStateChangeListener;
  StreamSubscription? scanResultsListener;

  Future<bool> checkIsEnabled() async {
    isEnabled = await FlutterBluePlus.isAvailable;
    return isEnabled;
  }

  void listenForServiceStatusChanges(VoidCallback? cb) {
    serviceStateChangeListener = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        isEnabled = state == BluetoothAdapterState.on;
      });

      if (cb != null) cb();
    });
  }

  void listenForScanStateChanges({
    required VoidCallback started,
    required VoidCallback stopped,
  }) {
    scanStateChangeListener = FlutterBluePlus.isScanning.listen(
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
    int timeout = 5,
    VoidCallback? started,
    VoidCallback? stopped,
  }) async {
    if (FlutterBluePlus.isScanningNow) {
      if (started != null) started();
      return;
    }

    try {
      if (started != null) started();

      setState(() {
        isScanning = true;
      });

      await FlutterBluePlus.startScan(timeout: Duration(seconds: timeout)).then((value) {
        if (stopped != null) stopped();

        setState(() {
          isScanning = false;
        });
      });
    } catch (e) {}
  }

  void stopScan(VoidCallback cb) {
    try {
      FlutterBluePlus.stopScan().then((value) {
        cb();
      });
    } catch (e) {}
  }

  void listenForScanResults(cb) {
    scanResultsListener = FlutterBluePlus.adapterState.listen((state) {
      FlutterBluePlus.scanResults.listen((results) {
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

    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }

    super.dispose();
  }
}

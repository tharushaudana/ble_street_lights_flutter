import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:flutter/material.dart';

abstract class IBLEDeviceConnectionProviderLink {
  void makeRequest(BLEDeviceRequest request);  
}

class BLEDeviceConnectionProvider extends ChangeNotifier implements IBLEDeviceConnectionProviderLink {
  BLEDeviceData deviceData = BLEDeviceData();

  late BLEDeviceConnectionProviderLink _link;

  bool isDisposed = false;

  BLEDeviceConnectionProvider(BLEDeviceConnectionProviderLink link) {
    _link = link;
    _link._connectionProvider = this;
    _link.initLink();
  }

  disposeProvider() {
    isDisposed = true;
  }

  _notify() {
    //if (isDisposed) return;
    if (!hasListeners) return;
    notifyListeners();
  }
  
  @override
  void makeRequest(BLEDeviceRequest request) {
    _link.makeRequest(request);
  }
}

class BLEDeviceConnectionProviderLink implements IBLEDeviceConnectionProviderLink {
  BLEDeviceConnectionProvider? _connectionProvider;
  
  notifyDeviceDataChange(BLEDeviceData deviceData) {
    _connectionProvider?.deviceData = deviceData;
    _connectionProvider?._notify();
  }

  initLink() {

  }
  
  @override
  void makeRequest(BLEDeviceRequest request) {
    // TODO: implement makeRequest
  }
}
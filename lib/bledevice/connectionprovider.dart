import 'package:ble_street_lights/bledevice/data.dart';
import 'package:flutter/material.dart';

abstract class IBLEDeviceConnectionProviderLink {
  void test();  
}

class BLEDeviceConnectionProvider extends ChangeNotifier implements IBLEDeviceConnectionProviderLink {
  BLEDeviceData deviceData = BLEDeviceData();

  late BLEDeviceConnectionProviderLink _link;

  BLEDeviceConnectionProvider(BLEDeviceConnectionProviderLink link) {
    _link = link;
    _link._connectionProvider = this;
    _link.initLink();
  }

  _notify() {
    notifyListeners();
  }
  
  @override
  void test() {
    _link.test();
  }
}

class BLEDeviceConnectionProviderLink implements IBLEDeviceConnectionProviderLink {
  BLEDeviceConnectionProvider? _connectionProvider;
  
  notifyDeviceDataChange(BLEDeviceData deviceData) {
    _connectionProvider?.deviceData = deviceData;
    _connectionProvider?._notify();
  }

  @override
  void test() {
    
  }

  initLink() {

  }
}
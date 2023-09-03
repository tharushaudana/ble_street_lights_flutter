import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:flutter/material.dart';

abstract class IBLEDeviceConnectionProviderLink {
  void makeRequest(BLEDeviceRequest request);
}

class BLEDeviceConnectionProvider extends ChangeNotifier
    implements IBLEDeviceConnectionProviderLink {
  BLEDeviceData deviceData = BLEDeviceData();

  late BLEDeviceConnectionProviderLink _link;

  BLEDeviceConnectionProvider(BLEDeviceConnectionProviderLink link) {
    _link = link;
    //_link._connectionProvider = this;
    _link.initLink(this);
  }

  _notify() {
    if (!hasListeners) return;

    try {
      notifyListeners();
      // ignore: empty_catches
    } catch (e) {}
  }

  bool _hasListeners() {
    return hasListeners;
  }

  @override
  void makeRequest(BLEDeviceRequest request) {
    _link.makeRequest(request);
  }
}

class BLEDeviceConnectionProviderLink
    implements IBLEDeviceConnectionProviderLink {
  late BLEDeviceData deviceData;

  final List<BLEDeviceConnectionProvider> _providers = [];

  notifyDeviceDataChange(BLEDeviceData deviceData, {int index = -1}) {
    if (index > -1) {
      _providers[index].deviceData = deviceData;
      _providers[index]._notify();
    } else {
      for (int i = _providers.length - 1; i > -1; i--) {
        //### remove disposed providers
        if (!_providers[i]._hasListeners()) {
          _providers.removeAt(i);
          continue;
        }
        //###
        _providers[i].deviceData = deviceData;
        _providers[i]._notify();        
      }
    }
  }

  initLink(BLEDeviceConnectionProvider provider) {
    _providers.add(provider);
    notifyDeviceDataChange(deviceData, index: _providers.length - 1);
  }

  @override
  void makeRequest(BLEDeviceRequest request) {
    // TODO: implement makeRequest
  }
}

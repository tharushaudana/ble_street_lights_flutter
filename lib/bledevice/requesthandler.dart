import 'dart:convert';
import 'package:ble_street_lights/bledevice/message.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDeviceRequestHandler {
  int _lastTokenId = 1000;

  Map<int, BLEDeviceRequest> requests = {};

  BluetoothCharacteristic? characteristic;

  handle(BLEDeviceRequest request) {
    if (characteristic == null) return;

    List<int> bytes = utf8.encode(request.buildJson(++_lastTokenId).trim());

    characteristic!.write(bytes);

    requests[_lastTokenId] = request;
  }

  watchForResponse(BLEDeviceMessage message) {
    if (!requests.containsKey(message.type)) return;

    BLEDeviceRequest request = requests[message.type]!;

    if (request.onSuccess != null) {
      request.onSuccess!(message);
    }
  }
}
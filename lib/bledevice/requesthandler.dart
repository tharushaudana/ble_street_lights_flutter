import 'dart:convert';
import 'dart:developer';
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

    try {
      //characteristic!.write(bytes);
      //characteristic!.write(bytes, withoutResponse: true);
      writeCharacteristic(bytes);
      /*Future.delayed(const Duration(seconds: 1), () async {
        await writeCharacteristic(bytes);
      });*/
      requests[_lastTokenId] = request;
    } catch (e) {
      request.onFailed!("Failed to Send!");
    }
  }

  writeCharacteristic(List<int> bytes) async {
    try {
      await characteristic!.write(bytes);
    } catch (e) {
      log(e.toString());
    }
  }

  watchForResponse(BLEDeviceMessage message) {
    if (!requests.containsKey(message.type)) return;

    BLEDeviceRequest request = requests[message.type]!;

    if (request.onSuccess != null) {
      request.onSuccess!(message);
    }

    requests.remove(message.type);
  }
}
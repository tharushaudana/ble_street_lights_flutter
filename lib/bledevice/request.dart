import 'dart:convert';

import 'package:ble_street_lights/bledevice/message.dart';
import 'package:ble_street_lights/time/time.dart';
import 'package:flutter/material.dart';

class BLEDeviceRequest {
  Map request = {};

  late DateTime buildAt;

  Function(BLEDeviceMessage response)? onSuccess;
  Function(String err)? onFailed;
  VoidCallback? onTimeOut;

  BLEDeviceRequest(String action) {
    request['a'] = action;
  }

  BLEDeviceRequest subject(String subject) {
    request['s'] = subject;
    return this;
  }

  BLEDeviceRequest data(Map data) {
    request['d'] = data;
    return this;
  }

  listen({
    Function(BLEDeviceMessage response)? onSuccess,
    Function(String err)? onFailed,
    VoidCallback? onTimeOut,
  }) {
    this.onSuccess = onSuccess;
    this.onFailed = onFailed;
    this.onTimeOut = onTimeOut;
  }

  String buildJson(int token) {
    request['t'] = token;
    buildAt = Time.now();
    return jsonEncode(request);
  }
}

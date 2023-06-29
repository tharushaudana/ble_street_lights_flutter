import 'dart:async';
import 'package:ble_street_lights/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

class LocationHelper extends Helper {
  bool isEnabled = false;

  StreamSubscription? serviceStateChangeListener;

  Future<bool> checkIsEnabled() async {
    isEnabled = await geolocator.GeolocatorPlatform.instance.isLocationServiceEnabled();
    return isEnabled;
  }

  void listenForServiceStatusChanges(cb) {
    serviceStateChangeListener = geolocator.GeolocatorPlatform.instance
        .getServiceStatusStream()
        .listen((geolocator.ServiceStatus status) {
      setState(() {
        isEnabled = status == geolocator.ServiceStatus.enabled;
      });

      if (cb != null) cb();
    });  
  }

  @override
  void dispose() {
    if (serviceStateChangeListener != null) {
      serviceStateChangeListener!.cancel();
    }

    super.dispose();
  }
}

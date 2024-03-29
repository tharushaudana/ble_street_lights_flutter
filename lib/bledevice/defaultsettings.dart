import 'package:ble_street_lights/backupableitrs/blist/blist.dart';
import 'package:ble_street_lights/backupableitrs/bmap/bmap.dart';
import 'package:flutter/material.dart';

Map getDefaultSettings() {
  return {
    
    'hometab': BMap({
      "mode": "manual",
      "lamps": BList([
        BMap({"pwm": 0, "rvalue": 0}),
        BMap({"pwm": 0, "rvalue": 0}),
        BMap({"pwm": 0, "rvalue": 0}),
        BMap({"pwm": 0, "rvalue": 0})
      ]),
    }),

    'astrotab': BMap({
      "enabled": false,
      "sunrise": 1,
      "sunset": 1,
    }),

    'settingstab': BMap({
      "motionSensor": BMap({
        "enabled": false,
        "sensorCount": 1,
        "holdTime": 1,
        "slevels": BList([0, 0]) // sensitive levels
      }),
      "dimmingStages": BMap({
        "enabled": false,
        "mode": "manual",
        "stages": BList([
          BMap({
            "pwm": 70,
            "from": const TimeOfDay(hour: 19, minute: 30),
            "to": const TimeOfDay(hour: 20, minute: 30),
          }),
          BMap({
            "pwm": 50,
            "from": const TimeOfDay(hour: 20, minute: 30),
            "to": const TimeOfDay(hour: 21, minute: 30),
          })
        ]),
      }),
    }),
    
  };
}

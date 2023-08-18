import 'package:flutter/material.dart';

class BLEDeviceData {
  bool isConnected = false;
  Map? currentValues;
  Map? settingValues;

  bool isLoadedSettingsDataForHomeTab = false;
  bool isLoadedSettingsDataForAstroTab = false;
  bool isLoadedSettingsDataForSettingsTab = false;

  bool loadSettingsDataForHomeTab(Map data) {
    if (currentValues == null) return false;

    data["mode"] = currentValue("m", 1) == 2 ? "astro" : "manual";

    data["lamps"] = [];

    for (String k in ['a', 'b', 'c', 'd']) {
      data["lamps"].add({
        "pwm": currentValue("w.$k", 0),
        "rvalue": currentValue("r.$k", 0),
      });
    }

    return true;
  }

  bool loadSettingsDataForAstroTab(Map data) {
    if (settingValues == null) return false;

    data["enabled"] = settingValue("o.s", 0) == 1;
    data["sunrise"] = settingValue("o.r", 0);
    data["sunset"] = settingValue("o.t", 0);

    return true;
  }

/**
    "dimmingStages": {
      "enabled": false,
      "mode": "manual",
      "stages": [
        {
          "pwm": 70,
          "from": const TimeOfDay(hour: 19, minute: 30),
          "to": const TimeOfDay(hour: 20, minute: 30),
        },
        {
          "pwm": 50,
          "from": const TimeOfDay(hour: 20, minute: 30),
          "to": const TimeOfDay(hour: 21, minute: 30),
        }
      ]
    },
 */

  bool loadSettingsDataForSettingsTab(Map data) {
    if (settingValues == null) return false;

    //#### Motion Sensor

    data["motionSensor"]["enabled"] = settingValue("m.s", 0) == 1;

    int sensorCount = settingValue("m.c", 0);
    if (sensorCount < 1 || sensorCount > 4) sensorCount = 1;

    int holdTime = settingValue("m.m", 0);
    if (sensorCount < 1 || sensorCount > 120) holdTime = 1;

    data["motionSensor"]["sensorCount"] = sensorCount;
    data["motionSensor"]["holdTime"] = holdTime;

    //#### Dimming Stages

    int status = settingValue("d.s", 0);
    data["dimmingStages"]["enabled"] = status == 1;
    if (status != 1) return true;

    int dimmingType = settingValue("d.t", 0);
    if (dimmingType == 1 || dimmingType == 2) {
      data["dimmingStages"]["mode"] = dimmingType == 1 ? "manual" : "gradual";
    }

    int stagesCount = settingValue("d.m", 0);
    if (stagesCount < 1) return true;

    data["dimmingStages"]["stages"] = [];

    for (int i = 0; i < stagesCount; i++) {
      int pwm = settingValue<List>("d.b", [])[i];
      String from = settingValue<List>("d.f", [])[i];
      String to = settingValue<List>("d.o", [])[i];

      data["dimmingStages"]["stages"].add({
        "pwm": pwm,
        "from": TimeOfDay(
          hour: int.parse(from.split(".")[0]),
          minute: int.parse(from.split(".")[1]),
        ),
        "to": TimeOfDay(
          hour: int.parse(to.split(".")[0]),
          minute: int.parse(to.split(".")[1]),
        ),
      });
    }

    print(data);

    return true;
  }

  settingValue<T>(String path, T noneValue) {
    if (settingValues == null || path.trim().isEmpty) return noneValue;
    return _getValue(settingValues!, path, noneValue);
  }

  currentValue<T>(String path, T noneValue) {
    if (currentValues == null || path.trim().isEmpty) return noneValue;
    return _getValue(currentValues!, path, noneValue);
  }

  _getValue<T>(Map source, String path, T noneValue) {
    List<String> keys = path.split(".");

    if (!source.containsKey(keys[0])) return noneValue;

    if (keys.length == 1) return source[keys[0]];

    Map sector = source[keys[0]];

    for (int i = 1; i < keys.length; i++) {
      if (!sector.containsKey(keys[i])) return noneValue;

      if (i == keys.length - 1) {
        try {
          return sector[keys[i]];
        } catch (e) {
          return noneValue;
        }
      } else {
        sector = sector[keys[i]];
      }
    }

    return noneValue;
  }
}

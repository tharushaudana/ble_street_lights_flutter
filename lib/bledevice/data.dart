class BLEDeviceData {
  bool isConnected = false;
  Map? currentValues;
  Map? settingValues;

  bool isLoadedSettingsDataForHomeTab = false;
  bool isLoadedSettingsDataForAstroTab = false;
  bool isLoadedSettingsDataForSettingsTab = false;

  loadSettingsDataForHomeTab(Map data) {
    if (isLoadedSettingsDataForHomeTab || currentValues == null) return; 
    isLoadedSettingsDataForHomeTab = true;

    data["mode"] = currentValue("m", 1) == 2 ? "astro" : "manual";

    data["lamps"] = [];

    for (String k in ['a', 'b', 'c', 'd']) {
      data["lamps"].add({
        "pwm": currentValue("w.$k", 0),
        "rvalue": currentValue("r.$k", 0),
      }); 
    }
  }

  loadSettingsDataForAstroTab(Map data) {
    if (isLoadedSettingsDataForAstroTab || settingValues == null) return; 
    isLoadedSettingsDataForAstroTab = true;

    data["enabled"] = settingValue("o.s", 0) == 1;
    data["sunrise"] = settingValue("o.r", 0);
    data["sunset"] = settingValue("o.t", 0);
  }

  loadSettingsDataForSettingsTab(Map data) {
    if (isLoadedSettingsDataForSettingsTab || settingValues == null) return; 
    isLoadedSettingsDataForSettingsTab = true;

    //#### Motion Sensor

    data["motionSensor"]["enabled"] = settingValue("m.s", 0) == 1;

    int sensorCount = settingValue("m.c", 0);
    if (sensorCount < 1 || sensorCount > 4) sensorCount = 1;

    int holdTime = settingValue("m.m", 0);
    if (sensorCount < 1 || sensorCount > 120) holdTime = 1;

    data["motionSensor"]["sensorCount"] = sensorCount;
    data["motionSensor"]["holdTime"] = holdTime;

    //#### Dimming Stages
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
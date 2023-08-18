import 'dart:developer';
import 'dart:ui';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:ble_street_lights/safestate/safestate.dart';
import 'package:ble_street_lights/screens/device/screens/settings/screens/dimmingstagessettingsscreen.dart';
import 'package:ble_street_lights/screens/device/screens/settings/screens/motionsensorsettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends SafeState<SettingsScreen>
    with AutomaticKeepAliveClientMixin<SettingsScreen> {
  Map settingsData = {
    "motionSensor": {
      "enabled": false,
      "sensorCount": 1,
      "holdTime": 1,
    },
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
  };

  Widget _settingCard(
    Widget child, {
    border = false,
    shadow = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 1),
                    blurRadius: 20,
                    //spreadRadius: 2,
                  ),
                ]
              : [],
          border: border
              ? Border.all(
                  width: 1,
                  color: Colors.blue,
                )
              : null,
          borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  List<T> _hidable<T>(int showUntil, List<T> list) {
    if (showUntil > list.length - 1) return [];

    if (showUntil == -1) showUntil = list.length - 1;

    List<T> show = [];

    for (int i = 0; i <= showUntil; i++) {
      show.add(list[i]);
    }

    return show;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isSettingsLoaded = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<BLEDeviceConnectionProvider>(builder: (
      context,
      provider,
      _,
    ) {

      if (!isSettingsLoaded && provider.deviceData.loadSettingsDataForSettingsTab(settingsData)) {
        isSettingsLoaded = true;
      }

      return Column(
        children: [
          const SizedBox(height: 15),
          _settingCard(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MotionSensorSettingsScreen(
                      provider: provider,
                      settingsData: settingsData["motionSensor"],
                      onClose: () {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          setState(() {});
                        });
                      },
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Motion Sensor",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: _hidable(
                              settingsData["motionSensor"]["enabled"] ? -1 : 0,
                              [
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              Table(
                                columnWidths: {
                                  0: FixedColumnWidth(120),
                                  1: FixedColumnWidth(70),
                                },
                                children: _hidable(
                                  settingsData["motionSensor"]["enabled"]
                                      ? -1
                                      : 0,
                                  [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: const Text(
                                            "STATUS: ",
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Text(
                                            settingsData["motionSensor"]
                                                    ["enabled"]
                                                ? "ON"
                                                : "OFF",
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: const Text(
                                              "SENSOR COUNT: ",
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Text(
                                              settingsData["motionSensor"]
                                                      ["sensorCount"]
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: const Text(
                                              "HOLD TIME: ",
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Text(
                                              "${settingsData["motionSensor"]["holdTime"]} min",
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  NeumorphismButton(
                    switched: settingsData["motionSensor"]["enabled"],
                    disabled: true,
                    glowEnabled: false,
                    onSwitching: (will) async {
                      return false;
                    },
                  ),
                ],
              ),
            ),
            shadow: true,
            border: true,
          ),
          _settingCard(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DimmingStagesSettingsScreen(
                      provider: provider,
                      settingsData: settingsData["dimmingStages"],
                      onClose: () {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          setState(() {});
                        });
                      },
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dimming Stages",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: _hidable(
                              settingsData["dimmingStages"]["enabled"] ? -1 : 0,
                              const [
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              Table(
                                columnWidths: {
                                  0: FixedColumnWidth(120),
                                  1: FixedColumnWidth(70),
                                },
                                children: _hidable(
                                  settingsData["dimmingStages"]["enabled"]
                                      ? -1
                                      : 0,
                                  [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: const Text(
                                            "STATUS: ",
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Text(
                                            settingsData["dimmingStages"]
                                                    ["enabled"]
                                                ? "ON"
                                                : "OFF",
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: const Text(
                                              "MODE: ",
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Text(
                                              settingsData["dimmingStages"]
                                                      ["mode"]
                                                  .toString()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: const Text(
                                              "COUNT: ",
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Text(
                                              settingsData["dimmingStages"]
                                                      ["stages"]
                                                  .length
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  NeumorphismButton(
                    switched: settingsData["dimmingStages"]["enabled"],
                    disabled: true,
                    glowEnabled: false,
                    onSwitching: (will) async {
                      return false;
                    },
                  ),
                ],
              ),
            ),
            shadow: true,
            border: true,
          ),
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

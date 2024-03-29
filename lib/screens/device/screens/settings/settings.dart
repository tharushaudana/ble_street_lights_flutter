import 'dart:developer';
import 'dart:ui';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/backupableitrs/bmap/bmap.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:ble_street_lights/safestate/safestate.dart';
import 'package:ble_street_lights/screens/device/screens/settings/screens/dimmingstagessettingsscreen.dart';
import 'package:ble_street_lights/screens/device/screens/settings/screens/motionsensorsettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onClickOpenFirmwareUpdate,
  });

  final VoidCallback onClickOpenFirmwareUpdate;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends SafeState<SettingsScreen> {
  late BMap settingsData;

  Widget _settingCard(
    Widget child, {
    border = false,
    shadow = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6,
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
                    color: Colors.grey.shade400,
                    offset: const Offset(0, 1.5),
                    blurRadius: 2,
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
    //settingsData.restoreBackup();
    super.dispose();
  }

  bool isSettingsLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BLEDeviceConnectionProvider>(builder: (
      context,
      provider,
      _,
    ) {
      if (!isSettingsLoaded) {
        provider.deviceData.loadSettingsData('settingstab', (data, success) {
          settingsData = data;
          isSettingsLoaded = success;
        });
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
                          fontSize: 17,
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
                                              "${settingsData["motionSensor"]["holdTime"]} sec",
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
                          fontSize: 17,
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
                              [
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 20,
                                ),
                                settingsData["dimmingStages"]["mode"] ==
                                        "manual"
                                    ? Icon(
                                        Icons.subdirectory_arrow_right_rounded,
                                        size: 20,
                                      )
                                    : Container(),
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
                                    settingsData["dimmingStages"]["mode"] ==
                                            "manual"
                                        ? TableRow(
                                            children: [
                                              TableCell(
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(top: 4),
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
                                                  margin:
                                                      EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    settingsData[
                                                                "dimmingStages"]
                                                            ["stages"]
                                                        .length
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : TableRow(
                                            children: [
                                              TableCell(child: Container()),
                                              TableCell(child: Container()),
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

          _settingCard(
            GestureDetector(
              onTap: () {
              },
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Advanced Settings",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
              },
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reboot Device",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                widget.onClickOpenFirmwareUpdate();
              },
              child: const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Firmware Update",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

import 'dart:developer';
import 'dart:ui';
import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:ble_street_lights/safestate/safestate.dart';
import 'package:ble_street_lights/screens/device/screens/settings/dimmingstagessettingsscreen.dart';
import 'package:ble_street_lights/screens/device/screens/settings/motionsensorsettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends SafeState<SettingsScreen> {
  Map settingsData = {
    "motionSensor": {
      "enabled": true,
      "sensorCount": 3,
      "holdTime": 50,
    },
    "dimmingStages": {
      "enabled": true,
      "stages": [
        {
          "pwm": 70,
          "start": "",
          "end": "",
        }
      ]
    },
  };

  Widget _valueBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(width: 1, color: Colors.blue)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.grey.shade400,
            size: 30,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neoBtnMotionSensor = NeumorphismButton(
      initialSwitched: settingsData["motionSensor"]["enabled"],
      glowEnabled: false,
      onSwitching: (will) {
        setState(() {
          //isOffsetStatusEnabled = will;
        });
        return true;
      },
    );

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
                    settingsData: settingsData["motionSensor"],
                    onClose: () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
                      "Motion Sensor Settings",
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
                          children: [
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
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Table(
                              columnWidths: {
                                0: FixedColumnWidth(120),
                                1: FixedColumnWidth(60),
                              },
                              children: [
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
                                        settingsData["motionSensor"]["enabled"]
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
                  onSwitching: (will) {
                    setState(() {
                      //isOffsetStatusEnabled = will;
                    });
                    return true;
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
                    settingsData: settingsData["dimmingStages"],
                    onClose: () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
                          children: [
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
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Table(
                              columnWidths: {
                                0: FixedColumnWidth(120),
                                1: FixedColumnWidth(60),
                              },
                              children: [
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
                                        settingsData["dimmingStages"]["enabled"]
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
                  onSwitching: (will) {
                    setState(() {
                      //isOffsetStatusEnabled = will;
                    });
                    return true;
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
  }
}

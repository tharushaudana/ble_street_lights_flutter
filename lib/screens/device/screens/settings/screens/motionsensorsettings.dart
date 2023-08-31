import 'dart:ui';
import 'package:ble_street_lights/backupableitrs/blist/blist.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/backupableitrs/bmap/bmap.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:ble_street_lights/screens/device/devicesyncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MotionSensorSettingsScreen extends StatefulWidget {
  const MotionSensorSettingsScreen({
    super.key,
    required this.provider,
    required this.settingsData,
    this.onClose,
  });

  final BLEDeviceConnectionProvider provider;
  final BMap settingsData;
  final VoidCallback? onClose;

  @override
  State<StatefulWidget> createState() => _MotionSensorSettingsScreenState();
}

class _MotionSensorSettingsScreenState
    extends State<MotionSensorSettingsScreen> {
  int _selectedSensorIndex = 0; // for configuration

  Future<bool> syncSettings(
    BLEDeviceConnectionProvider provider,
    Map data, {
    bool closeOnSuccess = false,
  }) async {
    bool b = await showDeviceSyncDialog(
      context: context,
      provider: provider,
      action: "set",
      subject: "msr",
      data: data,
      closeOnSuccess: closeOnSuccess,
      doSync: (
        dialogController,
        sendNow,
      ) {
        sendNow();
      },
    );

    if (b) {
      widget.settingsData.clearBackup();
    }

    return b;
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
        vertical: 5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
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

  int _sensitivePirCount() {
    BList list = widget.settingsData["config"];

    int c = 0;

    for (BMap item in list) {
      if (item["type"] == "sensitive") {
        c++;
      }
    }

    return c;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.settingsData.restoreBackup();
    if (widget.onClose != null) widget.onClose!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motion Sensor Settings"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 15),
            _settingCard(
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 20,
                          ),
                          Text(
                            widget.settingsData["enabled"] ? "ON" : "OFF",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  NeumorphismButton(
                    initialSwitched: widget.settingsData["enabled"],
                    glowEnabled: false,
                    onSwitching: (will) async {
                      setState(() {
                        widget.settingsData["enabled"] = will;
                      });

                      if (will) {
                        return true;
                      }

                      bool result = await syncSettings(
                        widget.provider,
                        {"e": will ? 1 : 0},
                        closeOnSuccess: true,
                      );

                      if (!result) {
                        WidgetsBinding.instance.addPostFrameCallback((
                          timeStamp,
                        ) {
                          setState(() {
                            widget.settingsData["enabled"] = !will;
                          });
                        });
                      }

                      return result;
                    },
                  ),
                ],
              ),
              shadow: false,
              border: true,
            ),
            widget.settingsData["enabled"]
                ? Column(
                    children: [
                      _settingCard(
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.auto_awesome_motion_rounded),
                                      SizedBox(width: 10),
                                      Text(
                                        "Sensor Count",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (widget.settingsData[
                                                  "sensorCount"] ==
                                              1) return;
                                          setState(() {
                                            widget
                                                .settingsData["sensorCount"]--;
                                          });
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () {
                                          if (widget.settingsData[
                                                  "sensorCount"] ==
                                              4) return;
                                          setState(() {
                                            widget
                                                .settingsData["sensorCount"]++;
                                          });
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.keyboard_arrow_up_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "${widget.settingsData['sensorCount']}",
                                  style: const TextStyle(
                                    fontSize: 35,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  "sensors",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _settingCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.settings),
                                SizedBox(width: 10),
                                Text(
                                  "Configuration",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                for (int i = 0; i < 4; i++)
                                  Opacity(
                                    opacity:
                                        widget.settingsData['sensorCount'] -
                                                    1 >=
                                                i
                                            ? 1
                                            : 0.3,
                                    child: InkWell(
                                      onTap: () {
                                        if (widget.settingsData['sensorCount'] -
                                                1 <
                                            i) {
                                          return;
                                        }

                                        setState(() {
                                          _selectedSensorIndex = i;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 15,
                                        ),
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                            color: _selectedSensorIndex == i
                                                ? Colors.blue
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: _selectedSensorIndex == i
                                                  ? Colors.blue
                                                  : Colors.black,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                          ['A', 'B', 'C', 'D'][i],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _selectedSensorIndex == i
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                ToggleButtons(
                                  onPressed: (index) {
                                    if (index == 0) {
                                      widget.settingsData["config"]
                                              [_selectedSensorIndex]["type"] =
                                          "normal";
                                    } else if (index == 1) {
                                      widget.settingsData["config"]
                                              [_selectedSensorIndex]["type"] =
                                          "sensitive";
                                    } else {
                                      return;
                                    }

                                    setState(() {});
                                  },
                                  constraints: const BoxConstraints(minHeight: 30),
                                  borderRadius: BorderRadius.circular(10),
                                  isSelected: [
                                    widget.settingsData["config"]
                                            [_selectedSensorIndex]["type"] ==
                                        "normal",
                                    widget.settingsData["config"]
                                            [_selectedSensorIndex]["type"] ==
                                        "sensitive",
                                  ],
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Text(
                                        "Normal",
                                        style: TextStyle(
                                          fontWeight: widget.settingsData[
                                                              "config"]
                                                          [_selectedSensorIndex]
                                                      ["type"] ==
                                                  "normal"
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: _sensitivePirCount() < 2 ? 1 : 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          "Sensitive",
                                          style: TextStyle(
                                            fontWeight: widget.settingsData[
                                                                "config"]
                                                            [_selectedSensorIndex]
                                                        ["type"] ==
                                                    "sensitive"
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                widget.settingsData["config"]
                                            [_selectedSensorIndex]['type'] ==
                                        "sensitive"
                                    ? SizedBox(
                                        width: 140,
                                        child: SfSlider(
                                          min: 25,
                                          max: 100,
                                          stepSize: 25,
                                          interval: 25,
                                          showTicks: true,
                                          showDividers: true,
                                          showLabels: true,
                                          value: widget.settingsData["config"]
                                                  [_selectedSensorIndex]
                                              ['sensitivity'],
                                          onChanged: (value) {
                                            setState(() {
                                              widget.settingsData["config"]
                                                          [_selectedSensorIndex]
                                                      ['sensitivity'] =
                                                  value.toInt();
                                            });
                                          },
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _settingCard(
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.timelapse_rounded),
                                      SizedBox(width: 10),
                                      Text(
                                        "Hold Time",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  SfSlider(
                                    min: 15,
                                    max: 300,
                                    interval: 57,
                                    showTicks: true,
                                    showLabels: true,
                                    showDividers: true,
                                    minorTicksPerInterval: 1,
                                    value: widget.settingsData['holdTime'],
                                    onChanged: (value) {
                                      if (value < 1) return;
                                      setState(() {
                                        widget.settingsData['holdTime'] =
                                            value.toInt();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "${widget.settingsData['holdTime']}",
                                  style: const TextStyle(
                                    fontSize: 35,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  "seconds",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            //########### configuration
                            final co = {};
                            final c = widget.settingsData["sensorCount"];

                            for (int i = 0; i < c; i++) {
                              final name = ['a', 'b', 'c', 'd'][i];

                              final t = widget.settingsData["config"][i]["type"];
                              final s = widget.settingsData["config"][i]["sensitivity"];

                              co[name] = {
                                't': t == "normal" ? 1 : 0
                              };

                              if (t == "sensitive") {
                                co[name]['s'] = s;
                              }
                            }
                            //###########

                            syncSettings(
                              widget.provider,
                              {
                                'e': 1,
                                'sc': widget.settingsData["sensorCount"],
                                'ht': widget.settingsData["holdTime"],
                                'co': co
                              },
                            );
                          },
                          child: const Text("UPDATE"),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 100.ms)
                : const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        "Turn on for show settings.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

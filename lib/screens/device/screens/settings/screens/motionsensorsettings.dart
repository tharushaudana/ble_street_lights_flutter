import 'dart:ui';
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
      body: Column(
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
                                        if (widget
                                                .settingsData["sensorCount"] ==
                                            1) return;
                                        setState(() {
                                          widget.settingsData["sensorCount"]--;
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
                                        if (widget
                                                .settingsData["sensorCount"] ==
                                            4) return;
                                        setState(() {
                                          widget.settingsData["sensorCount"]++;
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
                                Container(
                                  width: double.infinity,
                                  child: SfSlider(
                                    min: 0,
                                    max: 120,
                                    interval: 30,
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
                                "minutes",
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
                          syncSettings(
                            widget.provider,
                            {
                              'e': 1,
                              'sc': widget.settingsData["sensorCount"],
                              'ht': widget.settingsData["holdTime"],
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
    );
  }
}

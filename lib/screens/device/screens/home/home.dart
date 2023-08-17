import 'dart:developer';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/badgeswitch/badgeswitch.dart';
import 'package:ble_street_lights/components/swipecardswitch/swipecardswitch.dart';
import 'package:ble_street_lights/screens/device/screens/home/manualmode.dart';
import 'package:ble_street_lights/screens/device/screens/home/syncbtn.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class DeviceHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceHomeScreenState();
}

class _DeviceHomeScreenState extends State<DeviceHomeScreen>
    with AutomaticKeepAliveClientMixin<DeviceHomeScreen> {
  Map settingsData = {
    "mode": "manual",
    "lamps": [
      {"pwm": 20, "rvalue": 1},
      {"pwm": 40, "rvalue": 0},
      {"pwm": 50, "rvalue": 1},
      {"pwm": 75, "rvalue": 0}
    ]
  };

  int selectedLampIndex = 0;

  bool isSyncing = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<BLEDeviceConnectionProvider>(
      builder: (
        context,
        provider,
        _,
      ) {
        provider.deviceData.loadSettingsDataForHomeTab(settingsData);

        int motionSensorCount = provider.deviceData.settingValue("m.c", 0);

        Map motionSensorStates = provider.deviceData.currentValue<Map>("p", {});

        print("===============");
        print(motionSensorCount);
        print(motionSensorStates);

        return SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 15,
                  ),
                  margin: const EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.blue.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(0, 1),
                              blurRadius: 5,
                              //spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.model_training_rounded,
                              size: 30,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Device Mode",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            BadgeSwitch(
                              onSwitched: (childNo) {
                                setState(() {
                                  settingsData["mode"] =
                                      childNo == 1 ? "manual" : "astro";
                                });
                              },
                              initialSwitchedChild:
                                  settingsData["mode"] == "manual" ? 1 : 2,
                              disabled: isSyncing,
                              child1: Container(
                                width: 80,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  "Manual",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              child2: Container(
                                width: 80,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  "Astro",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(0, 1),
                              blurRadius: 5,
                              //spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Lamp Control",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: const Offset(0, 1),
                                        blurRadius: 5,
                                        //spreadRadius: 2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "230",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        "w",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            settingsData["mode"] == "manual"
                                ? ManualMode(
                                    settingsData: settingsData,
                                    selectedLampIndex: selectedLampIndex,
                                    onChangeSelectIndex: (index) {
                                      setState(() {
                                        selectedLampIndex = index;
                                      });
                                    },
                                    onChangeLampValue: (value) {
                                      setState(() {
                                        settingsData["lamps"][selectedLampIndex]
                                            ["pwm"] = value;
                                      });
                                    },
                                    onChangeRelayValue: (rvalue) {
                                      setState(() {
                                        settingsData["lamps"][selectedLampIndex]
                                            ["rvalue"] = rvalue;
                                      });
                                    },
                                  )
                                : Container(
                                    child: Center(
                                      child: Text("Not yet :("),
                                    ),
                                  )
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(0, 1),
                              blurRadius: 5,
                              //spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Motion Sensors",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < 4; i++)
                                  Opacity(
                                    opacity:
                                        motionSensorCount < i + 1 ? 0.5 : 1,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 15,
                                      ),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          width: 0.5,
                                          color: Colors.blue,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: const Offset(0, 1),
                                            blurRadius: 10,
                                            //spreadRadius: 2,
                                          ),
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.sensors_rounded,
                                        size: 20,
                                        color: motionSensorStates[['a', 'b', 'c', 'd'][i]] == 1 ? Colors.green : Colors.grey,
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
                ),
              ),
              SizedBox(
                height: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      height: 45,
                      width: 55,
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      margin: EdgeInsets.only(bottom: 150),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        border: Border.all(
                          width: 0.5,
                          color: Colors.grey.shade400,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: const Offset(0, 1),
                            blurRadius: 5,
                            //spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: SyncButton(
                        provider: provider,
                        action: "set",
                        subject: "hme",
                        onAnimStarted: () {
                          setState(() {
                            isSyncing = true;
                          });
                        },
                        onStartSync: () {
                          List b = [];
                          List r = [];

                          for (Map lamp in settingsData["lamps"]) {
                            b.add(lamp["pwm"]);
                            r.add(lamp["rvalue"]);
                          }

                          return {
                            "m": settingsData["mode"] == "manual" ? 1 : 2,
                            "b": b,
                            "r": r,
                          };
                        },
                        onResult: (completed) {
                          setState(() {
                            isSyncing = false;
                          });
                        },
                      ),
                      /*SpinKitThreeBounce(
                      color: Colors.blue,
                      size: 15,
                    ),*/
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 10,
    ),
    this.activeBottomMargin = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool activeBottomMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        bottom: activeBottomMargin ? 10 : 0,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 1),
            blurRadius: 3,
            //spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

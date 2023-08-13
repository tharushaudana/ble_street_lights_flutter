import 'dart:async';
import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:ble_street_lights/screens/device/dialogs/deviceconnectingdialog.dart';
import 'package:ble_street_lights/screens/device/screens/astro/astro.dart';
import 'package:ble_street_lights/screens/device/screens/home/home.dart';
import 'package:ble_street_lights/screens/device/screens/profile/profile.dart';
import 'package:ble_street_lights/screens/device/screens/settings/settings.dart';
import 'package:ble_street_lights/time/time.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    super.key,
    required this.deviceData,
    this.didPop,
  });

  final List deviceData;
  final VoidCallback? didPop;

  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late TabController _tabController;
  late BLEDevice device;

  bool isConnected = false;

  DateTime lastSeenTime = Time.now();
  Timer? timerLastSeenUpdate;
  String lastSeenStr = "recently";

  late AstroScreenController _astroScreenController;

  openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => BLEDeviceConnectionProvider(device),
          child: DeviceProfileScreen(
            deviceData: widget.deviceData,
          ),
        ),
      ),
    );
  }

  openConnectingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return DeviceConnectingDialog(device: device);
      },
    );
  }

  @override
  void initState() {
    device = BLEDevice(
      widget.deviceData[1],
      onConnected: () {
        setState(() {
          isConnected = true;
        });

        if (timerLastSeenUpdate != null && timerLastSeenUpdate!.isActive) {
          timerLastSeenUpdate!.cancel();
        }
      },
      onDisconnected: () {
        setState(() {
          isConnected = false;
        });

        lastSeenTime = Time.now();

        timerLastSeenUpdate = Timer.periodic(
          const Duration(seconds: 30),
          (timer) {
            setState(() {
              lastSeenStr = Time.dateTimeToHumanDiff(lastSeenTime);
            });
          },
        );
      },
      /*onMessage: (message) {
        log(message.type.toString());
        log(jsonEncode(message.data));
      },*/
    );

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        openConnectingDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index == 0) return true;

        if (_tabController.index == 1 &&
            _astroScreenController.isSettingsOpened) {
          _astroScreenController.closeSettings();
        } else {
          _tabController.index = 0;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Hero(
                      tag: 'img_profile',
                      child: Image(
                        image: AssetImage("assets/images/device_icon.png"),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          openProfileScreen();
                        },
                        child: Container(
                          height: 56,
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.deviceData[0]),
                              const SizedBox(height: 3),
                              Text(
                                isConnected ? "online" : "active $lastSeenStr",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          //elevation: 0,
          titleSpacing: 0,
        ),
        body: BottomTabBarLayout(
          tabs: [
            ["Home", Icons.home, Color(0xFF5B36B7)],
            ["Astro", Icons.wb_sunny_rounded, Color(0xFFC9379C)],
            ["Meter", Icons.energy_savings_leaf, Color(0xFFE6A91A)],
            ["Settings", Icons.settings_rounded, Color(0xFF1193A9)],
          ],
          onController: (controller) {
            _tabController = controller;
          },
          children: [
            ChangeNotifierProvider(
              create: (_) => BLEDeviceConnectionProvider(device),
              child: DeviceHomeScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => BLEDeviceConnectionProvider(device),
              child: AstroScreen(
                onController: (controller) {
                  _astroScreenController = controller;
                },
              ),
            ),
            Center(
                child: Text(
              "Meter",
              style: TextStyle(fontSize: 30),
            )),
            ChangeNotifierProvider(
              create: (_) => BLEDeviceConnectionProvider(device),
              child: SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    device.disconnect();

    if (timerLastSeenUpdate != null && timerLastSeenUpdate!.isActive) {
      timerLastSeenUpdate!.cancel();
    }

    if (widget.didPop != null) {
      widget.didPop!();
    }

    super.dispose();
  }
}

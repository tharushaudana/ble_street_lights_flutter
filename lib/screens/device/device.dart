import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:ble_street_lights/screens/device/deviceconnectingdialog.dart';
import 'package:ble_street_lights/screens/device/screens/profile/profile.dart';
import 'package:ble_street_lights/time/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    super.key,
    required this.deviceData,
  });

  final List deviceData;

  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late BLEDevice device;

  bool isConnected = false;

  DateTime lastSeenTime = Time.now();
  Timer? timerLastSeenUpdate;
  String lastSeenStr = "recently";

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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                openProfileScreen();
              },
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
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.deviceData[0]),
                      const SizedBox(height: 3),
                      Text(
                        isConnected ? "online" : "last seen $lastSeenStr",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: BottomTabBarLayout(
        tabs: [
          ["Home", Icons.home, Color(0xFF5B36B7)],
          ["Settings", Icons.settings, Color(0xFFC9379C)],
          ["Meter", Icons.energy_savings_leaf, Color(0xFFE6A91A)],
          ["Logs", Icons.list_alt, Color(0xFF1193A9)],
        ],
        children: [
          Center(
              child: Text(
            "Home",
            style: TextStyle(fontSize: 30),
          )),
          Center(
              child: Text(
            "Settings",
            style: TextStyle(fontSize: 30),
          )),
          Center(
              child: Text(
            "Meter",
            style: TextStyle(fontSize: 30),
          )),
          Center(
              child: Text(
            "Logs",
            style: TextStyle(fontSize: 30),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    device.disconnect();

    if (timerLastSeenUpdate != null && timerLastSeenUpdate!.isActive) {
      timerLastSeenUpdate!.cancel();
    }

    super.dispose();
  }
}

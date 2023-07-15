import 'dart:developer';

import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomnavigator.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:ble_street_lights/screens/device/deviceconnectingdialog.dart';
import 'package:ble_street_lights/screens/device/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    required this.deviceData,
  });

  final List deviceData;

  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late BLEDevice device;

  late BuildContext contextConnectingDialog;

  bool isTimeout = false;
  bool isConnected = false;

  openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceProfileScreen(
          deviceData: widget.deviceData,
        ),
      ),
    );
  }

  openConnectingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        //contextConnectingDialog = context;

        //if (isConnected) Navigator.pop(context);

        return DeviceConnectingDialog(device: device);
      },
    );
  }

  @override
  void initState() {
    device = BLEDevice(
      widget.deviceData[1],
      onConnected: () {
        //contextConnectingDialog.mo
        setState(() {
          isConnected = true;
        });
      },
      onDisconnected: () {
        setState(() {
          isConnected = false;
        });
      },
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
                  Text(widget.deviceData[0]),
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
    super.dispose();
  }
}

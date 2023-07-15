import 'dart:convert';
import 'dart:developer';
import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:ble_street_lights/screens/device/deviceconnectingdialog.dart';
import 'package:ble_street_lights/screens/device/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

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

  bool isConnected = false;

  openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => withChangeNotifierProvider(
          DeviceProfileScreen(
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

  withChangeNotifierProvider(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => BLEDeviceConnectionProvider(device),
      child: child,
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
      },
      onDisconnected: () {
        setState(() {
          isConnected = false;
        });
      },
      /*onMessage: (message) {
        log(message.type.toString());
        log(jsonEncode(message.data));
      },*/
    );

    linkDeviceAndConnectionProvider();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        openConnectingDialog();
      },
    );
  }

  linkDeviceAndConnectionProvider() {
    //final deviceConnectionProvider = Provider.of<BLEDeviceConnectionProvider>(context, listen: false);
    //deviceConnectionProvider.setLink(device);
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

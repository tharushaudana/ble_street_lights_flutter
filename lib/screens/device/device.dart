import 'package:ble_street_lights/components/bottomtabbarlayout/bottomnavigator.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:ble_street_lights/screens/device/screens/profile.dart';
import 'package:flutter/material.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    required this.name,
  });

  final String name;

  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceProfileScreen(),
      ),
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
                  Text(widget.name),
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
}

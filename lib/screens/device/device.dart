import 'package:ble_street_lights/components/bottomtabbarlayout/bottomnavigator.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:flutter/material.dart';

class DeviceScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyESP32"),
        elevation: 0,
      ),
      body: BottomTabBarLayout(
        tabs: [
          ["Home", Icons.home, Color(0xFF5B36B7)],
          ["Settings", Icons.settings, Color(0xFFC9379C)],
          ["Meter", Icons.energy_savings_leaf, Color(0xFFE6A91A)],
          ["Logs", Icons.list_alt, Color(0xFF1193A9)],
        ],
        children: [
          Center(child: Text("Home", style: TextStyle(fontSize: 30),)),
          Center(child: Text("Settings", style: TextStyle(fontSize: 30),)),
          Center(child: Text("Meter", style: TextStyle(fontSize: 30),)),
          Center(child: Text("Logs", style: TextStyle(fontSize: 30),)),
        ],
      ),
    );
  }
}
